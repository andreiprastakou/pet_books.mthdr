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
end
