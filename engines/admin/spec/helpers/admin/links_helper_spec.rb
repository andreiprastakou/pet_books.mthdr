require 'rails_helper'

RSpec.describe Admin::LinksHelper do
  describe '#admin_nav_collections_link' do
    it 'returns the correct link' do
      expect(helper.admin_nav_collections_link).to eq(['Collections', admin_collections_path])
    end
  end

  describe '#admin_nav_collection_link' do
    let(:collection) { build(:collection, name: 'Collection A') }

    it 'returns a quoted collection name' do
      expect(helper.admin_nav_collection_link(collection)).to eq('"Collection A"')
    end

    context 'when the collection name is too long' do
      let(:collection) { build(:collection, name: 'A' * 50) }

      it 'keeps 20 chars' do
        expect(helper.admin_nav_collection_link(collection)).to eq(
          '"AAAAAAAAAAAAAAAAA..."'
        )
      end
    end
  end

  describe '#admin_external_link_to' do
    context 'with a book wikipedia link' do
      let(:book) { create(:book, wiki_url: 'https://en.wikipedia.org/wiki/The_Hobbit') }

      it 'includes page/view counts and a fetch link' do
        result = helper.admin_external_link_to(book, book.wikipedia_external_link)

        expect(result).to include(
          'wikipedia',
          'fetch',
          admin_book_wikipedia_fetches_path(book)
        )
      end
    end

    context 'with a series wikipedia link' do
      let(:series) { create(:series, wiki_url: 'https://en.wikipedia.org/wiki/The_Lord_of_the_Rings') }

      it 'includes page/view counts without a fetch link' do
        result = helper.admin_external_link_to(series, series.wikipedia_external_link)

        expect(result).to include('wikipedia')
        expect(result).not_to include('>fetch<')
        expect(result).not_to include('wikipedia_fetches')
      end
    end
  end
end
