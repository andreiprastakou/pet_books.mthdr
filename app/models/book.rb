# frozen_string_literal: true

# == Schema Information
#
# Table name: books
#
#  id                   :integer          not null, primary key
#  data_filled          :boolean          default(FALSE), not null
#  goodreads_popularity :integer
#  goodreads_rating     :float
#  goodreads_url        :string
#  literary_form        :string           default("novel"), not null
#  original_title       :string
#  popularity           :integer          default(0)
#  summary              :text
#  summary_src          :string
#  title                :string           not null
#  wiki_popularity      :integer          default(0)
#  wiki_url             :string
#  year_published       :integer          not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  author_id            :integer          not null
#
# Indexes
#
#  index_books_on_author_id            (author_id)
#  index_books_on_data_filled          (data_filled)
#  index_books_on_title_and_author_id  (title,author_id) UNIQUE
#  index_books_on_year_published       (year_published)
#
class Book < ApplicationRecord
  STANDARD_FORMS = %w[
    novel
    novella
    short
    poem
    play
    comics
    non_fiction
  ].freeze

  include CarrierwaveUrlAssign

  belongs_to :author, class_name: 'Author', optional: true
  has_many :tag_connections, class_name: 'TagConnection', as: :entity, dependent: :destroy
  has_many :tags, through: :tag_connections, class_name: 'Tag'
  has_many :wiki_page_stats, as: :entity, class_name: 'WikiPageStat', dependent: :destroy
  has_many :genres, class_name: 'BookGenre', dependent: :destroy
  has_many :generative_summary_tasks, class_name: 'Admin::BookSummaryTask', as: :target, dependent: :destroy

  accepts_nested_attributes_for :tag_connections, allow_destroy: true
  accepts_nested_attributes_for :genres, allow_destroy: true

  validates :title, presence: true, uniqueness: { scope: :author_id }
  validates :author_id, presence: true
  validates :year_published, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :wiki_popularity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  before_validation :strip_title

  scope :with_tags, lambda { |tag_ids|
    includes(:tags).references(:tags).where(tags: { id: Array(tag_ids) })
  }
  scope :by_author, ->(author) { where(author_id: author) }
  scope :not_filled, -> { where(data_filled: false) }
  scope :without_tasks, -> { where.missing(:generative_summary_tasks) }

  def tag_ids
    tag_connections.map(&:tag_id)
  end

  def special_original_title?
    original_title.present? && original_title != title
  end

  def current_tag_names
    tag_connections.reject(&:marked_for_destruction?).map(&:tag).map(&:name)
  end

  def current_genre_names
    genres.reject(&:marked_for_destruction?).map(&:genre_name)
  end

  def current_book_genres
    genres.reject(&:marked_for_destruction?)
  end

  def genre_names=(names)
    names = names.map { |name| Genre.normalize_name_value(name) }
    book_genres_indexed = current_book_genres.index_by(&:genre_name)

    names.uniq.each do |name|
      next if book_genres_indexed.key?(name)

      genre = Genre.where(name: name).first_or_create!
      genres.build(genre: genre)
    end

    book_genres_indexed.each do |name, book_genre|
      book_genre.mark_for_destruction unless names.include?(name)
    end
  end

  def next_author_book
    self.class.where(author_id: author_id)
        .where('(year_published > ?) OR (year_published = ? AND id > ?)', year_published, year_published, id)
        .order(:year_published, :id)
        .limit(1)
        .first
  end

  def small?
    literary_form.in?(%w[short short_story])
  end

  protected

  def strip_title
    return if title.blank?

    title.strip!
  end
end
