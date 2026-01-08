# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
# Database name: primary
#
#  id         :integer          not null, primary key
#  category   :integer          default("other")
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_tags_on_category  (category)
#  index_tags_on_name      (name) UNIQUE
#
class Tag < ApplicationRecord
  include HasCodifiedName

  has_many :tag_connections, class_name: 'TagConnection', dependent: :destroy

  # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :book_tag_connections, -> { where(entity_type: Book.name) },
           class_name: 'TagConnection', inverse_of: :tag
  has_many :author_tag_connections, -> { where(entity_type: Author.name) },
           class_name: 'TagConnection', inverse_of: :tag
  # rubocop:enable Rails/HasManyOrHasOneDependent

  has_many :books, through: :book_tag_connections
  has_many :authors, through: :author_tag_connections

  enum :category, {
    other: 0,
    format: 1,
    genre: 2,
    location: 3,
    series: 4,
    award: 5,
    theme: 6
  }

  define_codified_attribute :name

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :category, presence: true

  scope :with_name, ->(name) { where(name: Array(name).map { |n| normalize_name_value(n) }) }
  scope :search_by_name, ->(key) { where('name LIKE ?', "%#{key}%") }

  def self.find_or_create_by_name(name, category)
    with_name(name).first ||
      create!(name: name, category: category.to_sym)
  end
end
