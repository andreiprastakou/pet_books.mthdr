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
class Book < ApplicationRecord
  FORMS_REQUIRE_SUMMARY = (%w[novel novella non_fiction play] + [nil]).freeze
  # Visual format derived from literary_form (not stored).
  FORMAT_NORMAL = 'normal'
  FORMAT_SMALL = 'small'
  FORMAT_BIG = 'big'
  FORMAT_COLLECTION = 'collection'
  FORMATS = [FORMAT_NORMAL, FORMAT_SMALL, FORMAT_BIG, FORMAT_COLLECTION].freeze
  FORMS_FORMAT_SMALL = %w[short short_story poem comics].freeze
  FORMS_FORMAT_BIG = %w[novel].freeze
  FORMS_FORMAT_COLLECTION = %w[collection].freeze

  include EqualByPersistedId
  include HasExternalLinks
  include HasDescriptions

  has_many :tag_connections, class_name: 'Joins::TagConnection', as: :entity, dependent: :destroy
  has_many :tags, through: :tag_connections, class_name: 'Tag'
  has_many :genres, class_name: 'Joins::BookGenre', dependent: :destroy
  has_many :book_authors, class_name: 'Joins::BookAuthor', dependent: :destroy, inverse_of: :book
  has_many :authors, through: :book_authors, class_name: 'Author', inverse_of: :books
  has_many :book_series, class_name: 'Joins::BookSeries', dependent: :destroy, inverse_of: :book
  has_many :series, through: :book_series, class_name: 'Series'
  has_many :book_collections_as_work,
           class_name: 'Joins::BookCollection',
           inverse_of: :book,
           dependent: :destroy
  has_many :collections, through: :book_collections_as_work, source: :collection
  has_many :book_collections_as_collection,
           class_name: 'Joins::BookCollection',
           foreign_key: :collection_id,
           inverse_of: :collection,
           dependent: :destroy
  has_many :collected_works, class_name: 'Book', through: :book_collections_as_collection, source: :book
  has_many :book_public_lists, class_name: 'Joins::BookPublicList', dependent: :destroy, inverse_of: :book
  has_many :public_lists, through: :book_public_lists, class_name: 'PublicList'
  has_many :external_links, class_name: 'ExternalLink', as: :owner, dependent: :destroy, inverse_of: :owner

  validates :title, presence: true
  validates :year_published, presence: true, numericality: { only_integer: true }
  validates :wiki_popularity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :validate_unique_title_per_author

  before_validation :strip_title

  scope :with_tags, lambda { |tag_ids|
    includes(:tags).references(:tags).where(tags: { id: Array(tag_ids) })
  }
  scope :by_author, ->(author) { joins(:book_authors).where(book_authors: { author_id: author }) }
  scope :by_series, ->(series) { joins(:book_series).where(book_series: { series_id: series }) }
  scope :search_by_title, ->(key) { where('title LIKE ?', "%#{key}%") }

  def readonly?
    true
  end

  def tag_ids
    tag_connections.map(&:tag_id)
  end

  def special_original_title?
    original_title.present? && original_title != title
  end

  def collection?
    literary_form.in?(FORMS_FORMAT_COLLECTION)
  end

  def collected_work_ids_newest_first
    return [] unless collection?

    if collected_works.loaded?
      collected_works.sort_by { |work| [-work.year_published, -work.id] }.map(&:id)
    else
      collected_works.order(year_published: :desc, id: :desc).ids
    end
  end

  # Cover/spine size class: normal (default), small, big (novels), collection.
  def format
    return FORMAT_SMALL if literary_form.in?(FORMS_FORMAT_SMALL)
    return FORMAT_BIG if literary_form.in?(FORMS_FORMAT_BIG)
    return FORMAT_COLLECTION if collection?

    FORMAT_NORMAL
  end

  def primary_description
    descriptions.first
  end

  def author_names_label
    return 'Unknown Author' if authors.empty?

    authors.map(&:fullname).join(', ')
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
