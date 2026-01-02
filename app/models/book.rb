# frozen_string_literal: true

# == Schema Information
#
# Table name: books
# Database name: primary
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
#
# Indexes
#
#  index_books_on_data_filled     (data_filled)
#  index_books_on_year_published  (year_published)
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

  has_many :tag_connections, class_name: 'TagConnection', as: :entity, dependent: :destroy
  has_many :tags, through: :tag_connections, class_name: 'Tag'
  has_many :wiki_page_stats, as: :entity, class_name: 'WikiPageStat', dependent: :destroy
  has_many :genres, class_name: 'BookGenre', dependent: :destroy
  has_many :generative_summary_tasks, class_name: 'Admin::BookSummaryTask', as: :target, dependent: :destroy
  has_many :book_authors, class_name: 'BookAuthor', dependent: :destroy, inverse_of: :book
  has_many :authors, through: :book_authors, class_name: 'Author', inverse_of: :books
  has_many :book_series, class_name: 'BookSeries', dependent: :destroy, inverse_of: :book
  has_many :series, through: :book_series, class_name: 'Series'
  has_many :book_collections, class_name: 'BookCollection', dependent: :destroy, inverse_of: :book
  has_many :collections, through: :book_collections, class_name: 'Collection'
  has_many :book_public_lists, class_name: 'BookPublicList', dependent: :destroy, inverse_of: :book
  has_many :public_lists, through: :book_public_lists, class_name: 'PublicList'

  validates :title, presence: true
  validates :year_published, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :wiki_popularity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :validate_unique_title_per_author

  before_validation :strip_title

  scope :with_tags, lambda { |tag_ids|
    includes(:tags).references(:tags).where(tags: { id: Array(tag_ids) })
  }
  scope :by_author, ->(author) { joins(:book_authors).where(book_authors: { author_id: author }) }
  scope :not_filled, -> { where(data_filled: false) }
  scope :without_tasks, -> { where.missing(:generative_summary_tasks) }

  def tag_ids
    tag_connections.map(&:tag_id)
  end

  def special_original_title?
    original_title.present? && original_title != title
  end

  def next_author_book
    author_ids = book_authors.map(&:author_id)
    self.class.by_author(author_ids)
        .where('(year_published > ?) OR (year_published = ? AND books.id > ?)', year_published, year_published, id)
        .order(:year_published, 'books.id')
        .limit(1)
        .first
  end

  def small?
    literary_form.in?(%w[short short_story poem comics])
  end

  def needs_data_fetch?
    generative_summary_tasks.reject(&:rejected?).empty? &&
      !data_filled? &&
      !small?
  end

  def author_names_label
    return 'Unknown Author' if authors.empty?

    authors.map(&:fullname).join(', ')
  end

  def legacy_author_id
    ActiveSupport::Deprecation.new.warn('Book#legacy_author_id is deprecated. Use Book#author_ids instead.')
    author_ids.first
  end

  protected

  def validate_unique_title_per_author
    return if title.blank?

    author_ids = book_authors.map(&:author_id)
    siblings = Book.by_author(author_ids).where.not(id: id)
    return unless siblings.pluck(:title).map(&:downcase).include?(title.downcase)

    errors.add(:title, 'must be unique per author')
  end

  def strip_title
    return if title.blank?

    title.strip!
  end
end
