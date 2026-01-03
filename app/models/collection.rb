# == Schema Information
#
# Table name: collections
# Database name: primary
#
#  id             :integer          not null, primary key
#  name           :string           not null
#  wiki_url       :string
#  year_published :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_collections_on_name  (name) UNIQUE
#
class Collection < ApplicationRecord
  include HasWikiLinks

  has_many :book_collections, dependent: :destroy
  has_many :books, through: :book_collections

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :year_published, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
