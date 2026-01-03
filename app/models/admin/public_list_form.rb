# == Schema Information
#
# Table name: public_lists
# Database name: primary
#
#  id                  :integer          not null, primary key
#  wiki_url            :string
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
  class PublicListForm < ::PublicList
    accepts_nested_attributes_for :book_public_lists, allow_destroy: true

    validate :validate_books_uniqueness

    private

    def validate_books_uniqueness
      book_public_lists.group_by(&:book_id).each do |book_id, book_public_lists|
        errors.add(:book_public_lists, "Book ID #{book_id} is duplicated") if book_public_lists.size > 1
      end
    end
  end
end
