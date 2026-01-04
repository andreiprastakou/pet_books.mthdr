class MoveGoodreadsUrlToGenericLinks < ActiveRecord::Migration[8.1]
  class BookStub < ApplicationRecord
    self.table_name = 'books'
  end

  class GenericLinkStub < ApplicationRecord
    self.table_name = 'generic_links'
  end

  def up
    BookStub.where.not(goodreads_url: nil).find_each do |book|
      GenericLinkStub.where(entity_type: 'Book', entity_id: book.id, name: 'goodreads').first_or_create!(
        url: book.goodreads_url
      )
    end
    remove_column :books, :goodreads_url
    remove_column :books, :goodreads_popularity
    remove_column :books, :goodreads_rating
  end

  def down
    add_column :books, :goodreads_url, :string
    add_column :books, :goodreads_popularity, :integer
    add_column :books, :goodreads_rating, :float
  end
end
