# == Schema Information
#
# Table name: collections
# Database name: primary
#
#  id             :integer          not null, primary key
#  name           :string           not null
#  year_published :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_collections_on_name  (name) UNIQUE
#
class Collection < ApplicationRecord
  has_many :book_collections, dependent: :destroy
  has_many :books, through: :book_collections

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :year_published, presence: true, numericality: { only_integer: true, greater_than: 0 }

  def book_ids=(new_book_ids)
    previous_book_ids = book_collections.map(&:book_id)
    new_book_ids = new_book_ids.uniq.compact_blank
    book_collections.each do |book_collection|
      book_collection.mark_for_destruction unless new_book_ids.include?(book_collection.book_id)
    end
    (new_book_ids - previous_book_ids).each do |id|
      book_collections.build(book_id: id)
    end
  end
end
