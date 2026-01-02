require 'rails_helper'

RSpec.describe Admin::FormsHelper do
  describe '#authors_to_badges_entries' do
    let(:authors) { [build_stubbed(:author, fullname: 'AUTHOR_A')] }

    it 'returns the correct entries' do
      expect(helper.authors_to_badges_entries(authors)).to eq(
        [{ label: 'AUTHOR_A', id: authors[0].id }]
      )
    end
  end

  describe '#series_to_badges_entries' do
    let(:series_list) { [build_stubbed(:series, name: 'SERIES_A')] }

    it 'returns the correct entries' do
      expect(helper.series_to_badges_entries(series_list)).to eq(
        [{ label: 'SERIES_A', id: series_list[0].id }]
      )
    end
  end

  describe '#books_to_badges_entries' do
    let(:books) { [build_stubbed(:book, title: 'BOOK_A', year_published: 2020, authors: [author])] }
    let(:author) { build_stubbed(:author, fullname: 'AUTHOR_A') }

    it 'returns the correct entries' do
      expect(helper.books_to_badges_entries(books)).to eq(
        [{ label: 'BOOK_A by AUTHOR_A, 2020', id: books[0].id }]
      )
    end
  end

  describe '#book_public_lists_to_input_entries' do
    let(:book_public_lists) { [build(:book_public_list, book: book, role: 'winner')] }
    let(:book) { build_stubbed(:book, title: 'BOOK_A', authors: [author], year_published: 2020) }
    let(:author) { build_stubbed(:author, fullname: 'AUTHOR_A') }

    it 'returns the correct entries' do
      expect(helper.book_public_lists_to_input_entries(book_public_lists)).to eq(
        [{ label: 'BOOK_A by AUTHOR_A, 2020', id: book_public_lists[0].id, book_id: book.id, role: 'winner' }]
      )
    end
  end
end
