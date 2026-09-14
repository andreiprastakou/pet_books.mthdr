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

  describe '#admin_nav_external_identity_link' do
    context 'with a book owner' do
      let(:book) { build_stubbed(:book) }
      let(:external_identity) do
        build_stubbed(:external_identity, owner: book, external_resource: :open_library, external_id: 'OL1W')
      end

      it 'returns a crumb with resource and external_id' do
        expect(helper.admin_nav_external_identity_link(book, external_identity)).to eq(
          ['Open Library: OL1W', admin_book_external_identity_path(book, external_identity)]
        )
      end
    end

    context 'with an author owner' do
      let(:author) { build_stubbed(:author) }
      let(:external_identity) do
        build_stubbed(:external_identity, owner: author, external_resource: :wikidata, external_id: 'Q892')
      end

      it 'returns a crumb linking to the author identity' do
        expect(helper.admin_nav_external_identity_link(author, external_identity)).to eq(
          ['Wikidata: Q892', admin_author_external_identity_path(author, external_identity)]
        )
      end
    end
  end
end
