# frozen_string_literal: true

# == Schema Information
#
# Table name: books
# Database name: primary
#
#  id              :integer          not null, primary key
#  data_filled     :boolean          default(FALSE), not null
#  literary_form   :string
#  original_title  :string
#  popularity      :integer          default(0)
#  title           :string           not null
#  wiki_popularity :integer          default(0)
#  year_published  :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_books_on_data_filled     (data_filled)
#  index_books_on_year_published  (year_published)
#
module Admin
  # rubocop:disable-next Metrics/ClassLength
  class Book < ::Book
    include Admin::Castable
    include Admin::HasWikipedia
    include Admin::HasExternalIdentities
    include Admin::HasDataFetchTaskHistory

    has_many :authors, through: :book_authors, class_name: 'Admin::Author', inverse_of: :books
    has_many :generative_summary_tasks, class_name: 'Admin::Tasks::AiBookFetch', as: :target, dependent: :destroy

    accepts_nested_attributes_for :tag_connections, allow_destroy: true
    accepts_nested_attributes_for :genres, allow_destroy: true
    accepts_nested_attributes_for :book_authors, allow_destroy: true
    accepts_nested_attributes_for :book_series, allow_destroy: true

    scope :not_filled, -> { where(data_filled: false) }
    scope :without_tasks, -> { where.missing(:generative_summary_tasks) }
    scope :form_requires_summary, -> { where(literary_form: FORMS_REQUIRE_SUMMARY) }

    def self.data_fetch_owner_type
      ::Book.name
    end

    def self.cast_collection(books)
      books.map { |book| cast(book) }
    end

    # Load Admin::Book rows for ids from a ::Book relation/association, with preloads.
    def self.for_scope(book_scope, *preloads)
      scope = where(id: book_scope.select(:id))
      preloads.present? ? scope.preload(*preloads) : scope
    end

    # Swap nested :book targets on join records so views get Admin::Book + preloads.
    def self.assign_to_association!(records, association_name, *preloads)
      id_method = :"#{association_name}_id"
      by_id = where(id: records.map(&id_method)).preload(*preloads).index_by(&:id)
      records.each do |record|
        record.association(association_name).target = by_id.fetch(record.public_send(id_method))
      end
    end

    def next_author_book
      author_ids = book_authors.map(&:author_id)
      self.class.by_author(author_ids)
          .where('(year_published > ?) OR (year_published = ? AND books.id > ?)', year_published, year_published, id)
          .order(:year_published, 'books.id')
          .limit(1)
          .first
    end

    def needs_data_fetch?
      generative_summary_tasks.none?(&:fetched?) &&
        !data_filled? &&
        literary_form.in?(FORMS_REQUIRE_SUMMARY)
    end

    def current_book_genres
      genres.reject(&:marked_for_destruction?)
    end

    def current_genre_names
      current_book_genres.map(&:genre_name)
    end

    def genre_names=(new_genre_names)
      sync_named_associations!(
        new_values: new_genre_names,
        previous_names: current_genre_names,
        normalize: ->(name) { Genre.normalize_name_value(name) },
        indexed: current_book_genres.index_by(&:genre_name),
        build: ->(name) { genres.build(genre: Genre.where(name: name).first_or_create!) }
      )
    end

    def author_ids=(ids)
      sync_join_ids!(ids, association: :book_authors, foreign_key: :author_id)
    end

    def series_ids=(ids)
      sync_join_ids!(ids, association: :book_series, foreign_key: :series_id)
    end

    def current_tag_names
      tag_connections.reject(&:marked_for_destruction?).map(&:tag).map(&:name)
    end

    def tag_names=(new_tag_names)
      sync_named_associations!(
        new_values: new_tag_names,
        previous_names: current_tag_names,
        normalize: ->(name) { Tag.normalize_name_value(name) },
        indexed: tag_connections.index_by { |tc| tc.tag.name },
        build: ->(name) { tag_connections.build(tag: Tag.where(name: name).first_or_create!) }
      )
    end

    private

    def sync_join_ids!(ids, association:, foreign_key:)
      join_records = public_send(association)
      replace_join_foreign_keys!(ids, join_records: join_records, foreign_key: foreign_key) do |id|
        join_records.build(foreign_key => id)
      end
    end

    def sync_named_associations!(new_values:, previous_names:, normalize:, indexed:, build:)
      names = prepare_input_values(new_values, &normalize)
      indexed.each do |name, record|
        record.mark_for_destruction unless names.include?(name)
      end
      (names - previous_names).each(&build)
    end

    def replace_join_foreign_keys!(new_ids, join_records:, foreign_key:, &)
      ids = prepare_input_values(new_ids)
      previous_ids = join_records.map(&foreign_key)
      join_records.each do |record|
        record.mark_for_destruction unless ids.include?(record.public_send(foreign_key))
      end
      (ids - previous_ids).each(&)
    end

    def prepare_input_values(values, &)
      values = values.map(&) if block_given?
      values.uniq.compact_blank
    end
  end
end
