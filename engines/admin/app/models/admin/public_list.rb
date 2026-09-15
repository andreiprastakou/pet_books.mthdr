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
module Admin
  class PublicList < ::PublicList
    include HasWikipedia
    include HasExternalIdentities

    belongs_to :public_list_type, class_name: 'Admin::PublicListType', inverse_of: :public_lists

    accepts_nested_attributes_for :book_public_lists, allow_destroy: true

    validate :validate_books_uniqueness

    def readonly?
      false
    end

    def self.cast(public_list)
      return public_list if public_list.is_a?(self)
      return new(public_list.attributes) if public_list.new_record?

      public_list.becomes(self)
    end

    private

    def validate_books_uniqueness
      book_public_lists.group_by(&:book_id).each do |book_id, book_public_lists|
        errors.add(:book_public_lists, "Book ID #{book_id} is duplicated") if book_public_lists.size > 1
      end
    end
  end
end
