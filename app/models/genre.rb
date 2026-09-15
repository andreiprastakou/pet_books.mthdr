# frozen_string_literal: true

# == Schema Information
#
# Table name: genres
# Database name: primary
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  cover_design_id :integer
#
# Indexes
#
#  index_genres_on_cover_design_id  (cover_design_id)
#  index_genres_on_name             (name) UNIQUE
#
# Foreign Keys
#
#  cover_design_id  (cover_design_id => cover_designs.id)
#
class Genre < ApplicationRecord
  include HasCodifiedName

  belongs_to :cover_design, class_name: 'CoverDesign', optional: true
  has_many :book_genres, class_name: 'Joins::BookGenre', dependent: :restrict_with_error
  has_many :books, through: :book_genres

  validates :name, presence: true, uniqueness: true

  define_codified_attribute :name

  def readonly?
    true
  end

  # Admin::Genre shares this table without STI; treat same-id rows as equal.
  def ==(other)
    if other.equal?(self)
      true
    elsif other.is_a?(::Genre)
      !new_record? && !other.new_record? && id == other.id
    else
      false
    end
  end
end
