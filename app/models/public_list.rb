# frozen_string_literal: true

# == Schema Information
#
# Table name: public_lists
# Database name: primary
#
#  id                  :integer          not null, primary key
#  year                :integer          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  public_list_type_id :integer          not null
#
# Indexes
#
#  index_public_lists_on_public_list_type_id           (public_list_type_id)
#  index_public_lists_on_public_list_type_id_and_year  (public_list_type_id,year) UNIQUE
#
# Foreign Keys
#
#  public_list_type_id  (public_list_type_id => public_list_types.id)
#
class PublicList < ApplicationRecord
  include HasExternalLinks

  belongs_to :public_list_type, class_name: 'PublicListType', inverse_of: :public_lists
  has_many :book_public_lists, class_name: 'Joins::BookPublicList', dependent: :destroy
  has_many :books, class_name: 'Book', through: :book_public_lists

  validates :year, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :public_list_type_id, uniqueness: { scope: :year }

  def readonly?
    true
  end

  # Admin::PublicList shares this table without STI; treat same-id rows as equal.
  def ==(other)
    if other.equal?(self)
      true
    elsif other.is_a?(::PublicList)
      !new_record? && !other.new_record? && id == other.id
    else
      false
    end
  end
end
