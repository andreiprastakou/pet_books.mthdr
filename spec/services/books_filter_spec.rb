require 'rails_helper'

RSpec.describe BooksFilter do
  describe '.filtered_scope' do
    subject(:result) { described_class.filtered_scope(params) }

    let(:params) { { foo: 'bar' } }
    let(:books) do
      [
        create(:book, year_published: 1900, tags: [], series: []),
        create(:book, year_published: 1901, tags: [tag_a], series: [series_a]),
        create(:book, year_published: 1902, tags: [tag_b], series: [series_b])
      ]
    end
    let(:tag_a) { create(:tag) }
    let(:tag_b) { create(:tag) }
    let(:series_a) { create(:series) }
    let(:series_b) { create(:series) }

    before { books }

    context 'without filters in params' do
      it 'returns the full scope' do
        expect(result).to match_array(books)
      end
    end

    context 'with :author_id' do
      let(:params) { { author_id: books[1].author_ids.first } }

      it 'returns only books of that author' do
        expect(result.to_a).to match_array(books.values_at(1))
      end
    end

    context 'with :author_ids' do
      let(:params) { { author_ids: books.values_at(0, 2).flat_map(&:author_ids) } }

      it 'returns only books of those authors' do
        expect(result.to_a).to match_array(books.values_at(0, 2))
      end
    end

    context 'with :tag_id' do
      let(:params) { { tag_id: tag_a.id } }

      it 'returns only books with that tag' do
        expect(result.to_a).to match_array(books.values_at(1))
      end
    end

    context 'with :tag_ids' do
      let(:params) { { tag_ids: [tag_a.id, tag_b.id] } }

      it 'returns only books with those tags' do
        expect(result.to_a).to match_array(books.values_at(1, 2))
      end
    end

    context 'with :series_id' do
      let(:params) { { series_id: series_a.id } }

      it 'returns only books in that series' do
        expect(result.to_a).to match_array(books.values_at(1))
      end
    end

    context 'with :series_ids' do
      let(:params) { { series_ids: [series_a.id, series_b.id] } }

      it 'returns only books in those series' do
        expect(result.to_a).to match_array(books.values_at(1, 2))
      end
    end

    context 'with :years' do
      let(:params) { { years: [1902] } }

      it 'returns onlt books published in those years' do
        expect(result.to_a).to match_array(books.values_at(2))
      end
    end

    context 'when a scope is given' do
      subject(:result) { described_class.filtered_scope(params, Book.where(id: books[0])) }

      it 'uses it' do
        expect(result.to_a).to match_array(books.values_at(0))
      end
    end
  end
end
