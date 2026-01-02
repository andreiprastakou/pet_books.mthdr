module Admin
  class PublicListForm < ::PublicList
    accepts_nested_attributes_for :book_public_lists, allow_destroy: true

    validate :validate_books_uniqueness

    private

    def validate_books_uniqueness
      book_public_lists.group_by(&:book_id).each do |book_id, book_public_lists|
        if book_public_lists.size > 1
          errors.add(:book_public_lists, "Book ID #{book_id} is duplicated")
        end
      end
    end
  end
end
