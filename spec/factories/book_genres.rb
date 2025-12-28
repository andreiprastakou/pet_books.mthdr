# == Schema Information
#
# Table name: book_genres
# Database name: primary
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  book_id    :integer          not null
#  genre_id   :integer
#
# Indexes
#
#  index_book_genres_on_book_id               (book_id)
#  index_book_genres_on_book_id_and_genre_id  (book_id,genre_id) UNIQUE
#  index_book_genres_on_genre_id              (genre_id)
#
# Foreign Keys
#
#  book_id   (book_id => books.id)
#  genre_id  (genre_id => genres.id)
#
FactoryBot.define do
  factory :book_genre, class: 'BookGenre' do
    genre { Genre.first || create(:genre) }
  end
end
