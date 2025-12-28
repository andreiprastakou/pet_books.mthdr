# frozen_string_literal: true

# == Schema Information
#
# Table name: book_authors
# Database name: primary
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  author_id  :integer          not null
#  book_id    :integer          not null
#
# Indexes
#
#  index_book_authors_on_author_id              (author_id)
#  index_book_authors_on_book_id                (book_id)
#  index_book_authors_on_book_id_and_author_id  (book_id,author_id) UNIQUE
#
# Foreign Keys
#
#  author_id  (author_id => authors.id)
#  book_id    (book_id => books.id)
#
class BookAuthor < ApplicationRecord
  belongs_to :book, inverse_of: :book_authors
  belongs_to :author, inverse_of: :book_authors
end
