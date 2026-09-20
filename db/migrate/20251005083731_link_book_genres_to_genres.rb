class LinkBookGenresToGenres < ActiveRecord::Migration[8.0]
  class GenreStub < ApplicationRecord
    self.table_name = 'genres'
  end

  class BookGenreStub < ApplicationRecord
    self.table_name = 'book_genres'
  end

  def up
    add_reference :book_genres, :genre, foreign_key: true, null: true

    BookGenreStub.distinct.pluck(:name).each do |name|
      genre = GenreStub.find_or_create_by(name: name)
      BookGenreStub.where(name: name).update_all(genre_id: genre.id)
    end

    remove_index :book_genres, %i[book_id name]
    remove_column :book_genres, :name
    add_index :book_genres, %i[book_id genre_id], unique: true
  end

  def down
    add_column :book_genres, :name, :string, null: true

    GenreStub.find_each do |genre|
      BookGenreStub.where(genre: genre).update_all(name: genre.name)
    end

    remove_index :book_genres, %i[book_id genre_id]
    remove_reference :book_genres, :genre, foreign_key: true
  end
end
