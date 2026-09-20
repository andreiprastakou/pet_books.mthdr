# == Schema Information
#
# Table name: external_links
# Database name: primary
#
#  id                :integer          not null, primary key
#  external_resource :string           not null
#  locale            :string
#  owner_type        :string           not null
#  url               :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  owner_id          :integer          not null
#
# Indexes
#
#  index_external_links_on_owner_type_and_owner_id  (owner_type,owner_id)
#
require 'rails_helper'

RSpec.describe ExternalLink do
  subject(:link) { build(:external_link) }

  describe 'associations' do
    it { is_expected.to belong_to(:owner).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:owner_type) }
    it { is_expected.to validate_presence_of(:external_resource) }
    it { is_expected.to validate_presence_of(:url) }

    it 'has a valid factory' do
      expect(build(:external_link, owner: build_stubbed(:book))).to be_valid
    end
  end

  describe '.for_frontend' do
    let(:book) { create(:book) }
    let!(:wikipedia_link) do
      create(:external_link, owner: book, external_resource: ExternalResources::WIKIPEDIA,
                             url: 'https://en.wikipedia.org/wiki/Book')
    end
    let!(:wikidata_link) do
      create(:external_link, owner: book, external_resource: ExternalResources::WIKIDATA,
                             url: 'https://www.wikidata.org/wiki/Q1')
    end

    it 'excludes internal resources' do
      expect(described_class.for_frontend).to contain_exactly(wikipedia_link)
      expect(described_class.for_frontend).not_to include(wikidata_link)
    end
  end

  describe '.frontend_payload' do
    let(:wikipedia_link) do
      build(:external_link, external_resource: ExternalResources::WIKIPEDIA,
                            url: 'https://en.wikipedia.org/wiki/Book')
    end
    let(:wikidata_link) do
      build(:external_link, external_resource: ExternalResources::WIKIDATA,
                            url: 'https://www.wikidata.org/wiki/Q1')
    end

    it 'serializes only non-internal links with display labels' do
      expect(described_class.frontend_payload([wikipedia_link, wikidata_link])).to eq(
        [{
          external_resource: ExternalResources::WIKIPEDIA,
          label: 'Wikipedia',
          url: 'https://en.wikipedia.org/wiki/Book'
        }]
      )
    end
  end
end
