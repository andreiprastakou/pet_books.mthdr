require 'rails_helper'

RSpec.describe Forms::Admin::BooksBatchUpdater do
  describe '#update' do
    subject(:update) { updater.update(batch_params) }

    let(:updater) { described_class.new }
    let(:batch_params) do
      {
        0 => {
          id: book_a.id,
          title: 'TITLE_A_UPDATED'
        },
        1 => {
          title: 'TITLE_B',
          original_title: 'ORIGINAL_TITLE_B',
          literary_form: 'novel',
          year_published: '2025',
          author_ids: [author.id],
          wiki_url: 'https://en.wikipedia.org/wiki/Book_B'
        }
      }
    end
    let(:book_a) { create(:book, authors: [author], title: 'TITLE_A') }
    let(:author) { create(:author) }

    before { book_a }

    it 'updates books with IDs' do
      update
      expect(book_a.reload.title).to eq 'TITLE_A_UPDATED'
    end

    it 'creates books with no IDs' do
      expect { update }.to change(Book, :count).by(1)
      book_b = Book.last
      aggregate_failures do
        expect(book_b.title).to eq 'TITLE_B'
        expect(book_b.original_title).to eq 'ORIGINAL_TITLE_B'
        expect(book_b.literary_form).to eq 'novel'
        expect(book_b.year_published).to eq 2025
        expect(book_b.authors.map(&:id)).to eq [author.id]
        expect(book_b.wiki_url).to eq 'https://en.wikipedia.org/wiki/Book_B'
      end
    end

    it 'returns true on success' do
      expect(update).to be true
    end

    it 'exposes updated books' do
      update
      expect(updater.books).to contain_exactly(book_a, kind_of(Book))
      expect(updater.books.last.title).to eq 'TITLE_B'
    end

    context 'with invalid params' do
      before do
        batch_params[2] = batch_params[1].dup
        batch_params[1][:title] = ''
      end

      it 'returns false and does not update books' do
        expect { update }.not_to change(Book, :count)
        expect(update).to be false
        expect(book_a.reload.title).to eq 'TITLE_A'
      end

      it 'exposes books with errors' do
        update
        expect(updater.books).to contain_exactly(book_a, kind_of(Book), kind_of(Book))
        expect(updater.books[1].errors).to be_present
        expect(updater.books[1].errors[:title]).to include("can't be blank")
      end
    end
  end
end
