require 'rails_helper'

RSpec.describe BooksHelper do
  describe '#book_cover_design' do
    subject(:result) { helper.book_cover_design(book) }

    let(:book) { build_stubbed(:book, genres: book_genres) }
    let(:book_genres) { [build_stubbed(:book_genre, genre: genre)] }
    let(:genre) { build_stubbed(:genre, cover_design: cover_design) }
    let(:cover_design) { build_stubbed(:cover_design, name: 'cover_design') }
    let(:default_design) { build_stubbed(:cover_design, name: 'default') }

    before { allow(helper).to receive(:default_book_cover_design).and_return(default_design) }

    it 'returns a book cover design' do
      expect(result).to eq(cover_design)
    end

    context 'when genre has no design' do
      let(:genre) { build_stubbed(:genre, cover_design: nil) }

      it 'returns a default design' do
        expect(result).to eq(default_design)
      end

      context 'when no default design is set' do
        let(:default_design) { nil }

        it 'raises an error' do
          expect { result }.to raise_error('No default cover design!')
        end
      end
    end

    context 'when book has no genres' do
      let(:book) { build_stubbed(:book, genres: []) }

      it 'returns a default design' do
        expect(result).to eq(default_design)
      end

      context 'when no default design is set' do
        let(:default_design) { nil }

        it 'raises an error' do
          expect { result }.to raise_error('No default cover design!')
        end
      end
    end
  end

  describe '#default_book_cover_design' do
    subject(:result) { helper.default_book_cover_design }

    let(:default_design) { build_stubbed(:cover_design, name: 'default') }

    before { allow(CoverDesign).to receive(:default).and_return(default_design) }

    it 'returns a cached default design' do
      expect(result).to eq(default_design)
      result
      expect(CoverDesign).to have_received(:default).once
    end
  end

  describe '#cover_background_style' do
    subject(:result) { helper.cover_background_style(0) }

    it 'returns the shared cover palette CSS' do
      expect(result).to eq(CoverPalettes.background_css_for_id(0))
    end
  end
end
