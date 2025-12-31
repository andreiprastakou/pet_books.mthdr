class BookPublicList < ApplicationRecord
  belongs_to :book, class_name: 'Book', inverse_of: :book_public_lists
  belongs_to :public_list, class_name: 'PublicList', inverse_of: :book_public_lists

  validates :book_id, uniqueness: { scope: :public_list_id }
end
