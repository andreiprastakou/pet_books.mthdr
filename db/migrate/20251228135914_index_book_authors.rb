class IndexBookAuthors < ActiveRecord::Migration[8.1]
  def change
    add_index :book_authors, %i[book_id author_id], unique: true
  end
end
