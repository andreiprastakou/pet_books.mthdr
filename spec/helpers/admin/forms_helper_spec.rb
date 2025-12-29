require 'rails_helper'

RSpec.describe Admin::FormsHelper, type: :helper do
  describe '#book_authors_to_badges_entries' do
    let(:book) { build(:book, authors: [author]) }
    let(:author) { create(:author, fullname: 'AUTHOR_A') }

    it 'returns the correct entries' do
      expect(helper.book_authors_to_badges_entries(book)).to eq(
        [{ label: 'AUTHOR_A', id: author.id }]
      )
    end
  end

  describe '#book_series_to_badges_entries' do
    let(:book) { build(:book, series: [series]) }
    let(:series) { create(:series, name: 'SERIES_A') }

    it 'returns the correct entries' do
      expect(helper.book_series_to_badges_entries(book)).to eq(
        [{ label: 'SERIES_A', id: series.id }]
      )
    end
  end

  describe '#collection_books_to_badges_entries' do
    let(:collection) { build(:collection, books: [book]) }
    let(:book) { create(:book, title: 'BOOK_A', year_published: 2020, authors: [author]) }
    let(:author) { create(:author, fullname: 'AUTHOR_A') }

    it 'returns the correct entries' do
      expect(helper.collection_books_to_badges_entries(collection)).to eq(
        [{ label: 'BOOK_A by AUTHOR_A, 2020', id: book.id }]
      )
    end
  end
end
