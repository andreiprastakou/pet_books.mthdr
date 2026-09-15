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
#  summary         :text
#  summary_src     :string
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
  class Book < ::Book
    include HasWikipedia

    has_many :authors, through: :book_authors, class_name: 'Admin::Author', inverse_of: :books
    has_many :generative_summary_tasks, class_name: 'Admin::BookSummaryTask', as: :target, dependent: :destroy
    has_many :external_identities, class_name: 'Admin::ExternalIdentity', as: :owner, dependent: :destroy,
                                   inverse_of: :owner

    accepts_nested_attributes_for :tag_connections, allow_destroy: true
    accepts_nested_attributes_for :genres, allow_destroy: true
    accepts_nested_attributes_for :book_authors, allow_destroy: true
    accepts_nested_attributes_for :book_series, allow_destroy: true

    scope :not_filled, -> { where(data_filled: false) }
    scope :without_tasks, -> { where.missing(:generative_summary_tasks) }
    scope :form_requires_summary, -> { where(literary_form: FORMS_REQUIRE_SUMMARY) }

    def readonly?
      false
    end

    def self.cast(book)
      return book if book.is_a?(self)
      return new(book.attributes) if book.new_record?

      book.becomes(self)
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

    def history_data_fetch_tasks
      book_fetch_tasks = Admin::BaseDataFetchTask.where(
        target_type: ::Book.name,
        target_id: id
      )
      identities_fetch_tasks = Admin::BaseDataFetchTask.where(
        target_type: Admin::ExternalIdentity.name,
        target_id: external_identities.select(:id)
      )
      (book_fetch_tasks.to_a + identities_fetch_tasks.to_a)
        .sort_by(&:updated_at)
        .reverse
    end

    def current_book_genres
      genres.reject(&:marked_for_destruction?)
    end

    def current_genre_names
      current_book_genres.map(&:genre_name)
    end

    def genre_names=(new_genre_names)
      previous_genre_names = current_genre_names
      new_genre_names = prepare_input_values(new_genre_names) { |name| Genre.normalize_name_value(name) }
      book_genres_indexed = current_book_genres.index_by(&:genre_name)

      book_genres_indexed.each do |name, book_genre|
        book_genre.mark_for_destruction unless new_genre_names.include?(name)
      end

      (new_genre_names - previous_genre_names).each do |name|
        genres.build(genre: Genre.where(name: name).first_or_create!)
      end
    end

    def author_ids=(new_author_ids)
      previous_author_ids = book_authors.map(&:author_id)
      new_author_ids = prepare_input_values(new_author_ids)
      book_authors.each do |book_author|
        book_author.mark_for_destruction unless new_author_ids.include?(book_author.author_id)
      end

      (new_author_ids - previous_author_ids).each do |id|
        book_authors.build(author_id: id)
      end
    end

    def series_ids=(new_series_ids)
      previous_series_ids = book_series.map(&:series_id)
      new_series_ids = prepare_input_values(new_series_ids)

      book_series.each do |book_series|
        book_series.mark_for_destruction unless new_series_ids.include?(book_series.series_id)
      end

      (new_series_ids - previous_series_ids).each do |id|
        book_series.build(series_id: id)
      end
    end

    def current_tag_names
      tag_connections.reject(&:marked_for_destruction?).map(&:tag).map(&:name)
    end

    def tag_names=(new_tag_names)
      previous_tag_names = current_tag_names
      new_tag_names = prepare_input_values(new_tag_names) { |name| Tag.normalize_name_value(name) }
      tag_connections.each do |tag_connection|
        tag_connection.mark_for_destruction unless new_tag_names.include?(tag_connection.tag.name)
      end

      (new_tag_names - previous_tag_names).each do |name|
        tag_connections.build(tag: Tag.where(name: name).first_or_create!)
      end
    end

    private

    def prepare_input_values(values, &)
      values = values.map(&) if block_given?
      values.uniq.compact_blank
    end
  end
end
