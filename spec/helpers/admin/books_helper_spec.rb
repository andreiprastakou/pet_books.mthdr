require 'rails_helper'

RSpec.describe Admin::BooksHelper do
  describe '#book_label_for_badges' do
    let(:book) { build(:book, title: 'BOOK_A', year_published: 2020, authors: [author]) }
    let(:author) { create(:author, fullname: 'AUTHOR_A') }

    it 'returns the correct label' do
      expect(helper.book_label_for_badges(book)).to eq(
        'BOOK_A by AUTHOR_A, 2020'
      )
    end
  end

  describe '#book_title_marked_for_data_fetch' do
    subject(:result) { helper.book_title_marked_for_data_fetch(book) }

    let(:book) { build(:book, title: 'BOOK_A', literary_form: 'novel') }

    before { allow(book).to receive(:needs_data_fetch?).and_return(true) }

    context 'when the book needs data fetch' do
      it 'returns title wrapped in a text-danger' do
        expect(result).to eq(
          '<span class="text-danger">BOOK_A</span>'
        )
      end
    end

    context 'when the book does not need data fetch' do
      before { allow(book).to receive(:needs_data_fetch?).and_return(false) }

      it 'returns the title' do
        expect(result).to eq('BOOK_A')
      end
    end
  end

  describe '#book_wiki_link' do
    subject(:result) { helper.book_wiki_link(book) }

    let(:book) { build(:book, wiki_url: 'https://en.wikipedia.org/wiki/BOOK_A', wiki_popularity: 100) }

    it 'returns link + views count' do
      expect(result).to include book.wiki_url
      expect(result).to include '(100)'
    end

    context 'when the book has no wiki_popularity' do
      before { book.wiki_popularity = 0 }

      it 'returns link' do
        expect(result).not_to include '(0)'
      end
    end

    context 'when the book has no wiki_url' do
      before { book.wiki_url = nil }

      it { is_expected.to be_nil }
    end
  end
end
