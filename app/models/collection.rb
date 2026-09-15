# frozen_string_literal: true

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
  include HasExternalLinks

  has_many :book_collections, class_name: 'Joins::BookCollection', dependent: :destroy
  has_many :books, through: :book_collections

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :year_published, presence: true, numericality: { only_integer: true, greater_than: 0 }

  def readonly?
    true
  end

  # Admin::Collection shares this table without STI; treat same-id rows as equal.
  def ==(other)
    if other.equal?(self)
      true
    elsif other.is_a?(::Collection)
      !new_record? && !other.new_record? && id == other.id
    else
      false
    end
  end
end
