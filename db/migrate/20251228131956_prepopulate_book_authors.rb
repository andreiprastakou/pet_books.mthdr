class PrepopulateBookAuthors < ActiveRecord::Migration[8.1]
  class BookStub < ApplicationRecord
    self.table_name = 'books'
  end

  class BookAuthorStub < ApplicationRecord
    self.table_name = 'book_authors'
  end

  def up
    BookStub.find_each do |book|
      BookAuthorStub.where(book_id: book.id, author_id: book.author_id).first_or_create!
    end
  end

  def down; end
end
