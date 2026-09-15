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
  FORMS_REQUIRE_SUMMARY = (%w[novel novella non_fiction play] + [nil]).freeze
  FORMS_SMALL = %w[short short_story poem comics].freeze

  include HasExternalLinks

  has_many :tag_connections, class_name: 'TagConnection', as: :entity, dependent: :destroy
  has_many :tags, through: :tag_connections, class_name: 'Tag'
  has_many :genres, class_name: 'BookGenre', dependent: :destroy
  has_many :book_authors, class_name: 'BookAuthor', dependent: :destroy, inverse_of: :book
  has_many :authors, through: :book_authors, class_name: 'Author', inverse_of: :books
  has_many :book_series, class_name: 'BookSeries', dependent: :destroy, inverse_of: :book
  has_many :series, through: :book_series, class_name: 'Series'
  has_many :book_collections, class_name: 'BookCollection', dependent: :destroy, inverse_of: :book
  has_many :collections, through: :book_collections, class_name: 'Collection'
  has_many :book_public_lists, class_name: 'BookPublicList', dependent: :destroy, inverse_of: :book
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

  # Admin::Book shares this table without STI; treat same-id rows as equal.
  def ==(other)
    if other.equal?(self)
      true
    elsif other.is_a?(::Book)
      !new_record? && !other.new_record? && id == other.id
    else
      false
    end
  end

  def tag_ids
    tag_connections.map(&:tag_id)
  end

  def special_original_title?
    original_title.present? && original_title != title
  end

  def small?
    literary_form.in?(FORMS_SMALL)
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
