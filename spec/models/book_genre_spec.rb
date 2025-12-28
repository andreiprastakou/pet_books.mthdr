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
require 'rails_helper'

RSpec.describe BookGenre do
  subject { build(:book_genre) }

  describe 'validations' do
    it { is_expected.to belong_to(:genre).required }
    it { is_expected.to belong_to(:book).required }
  end

  describe '#genre_name' do
    subject(:result) { book_genre.genre_name }

    let(:book_genre) { build(:book_genre, genre: build_stubbed(:genre, name: 'literary')) }

    it 'returns the name of the genre' do
      expect(result).to eq('literary')
    end
  end
end
