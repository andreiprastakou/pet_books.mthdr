# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Wikidata::EntityLookup do
  describe '.cache_from_item!' do
    let(:item) do
      {
        'id' => 'Q545151',
        'labels' => { 'en' => 'The Spy Who Loved Me' },
        'descriptions' => { 'en' => 'James Bond novel' }
      }
    end
    let(:usable_values) { { 'authors' => ['Q82104'], 'open_library_id' => 'OL85742W' } }
    let(:labels_fetcher) { instance_double(Admin::InfoFetchers::Wikidata::Api::EntitiesLabelsFetcher) }

    before do
      allow(Admin::InfoFetchers::Wikidata::Api::EntitiesLabelsFetcher).to receive(:new).and_return(labels_fetcher)
      allow(labels_fetcher).to receive(:fetch).with(['Q82104']).and_return(
        'Q82104' => { 'label' => 'Ian Fleming', 'description' => 'English author' }
      )
    end

    it 'upserts the main item and referenced Q-IDs' do
      expect { described_class.cache_from_item!(item, usable_values: usable_values) }
        .to change(Admin::WikidataLookupEntity, :count).by(2)

      main = Admin::WikidataLookupEntity.find_by!(qid: 'Q545151')
      expect(main.label).to eq('The Spy Who Loved Me')
      expect(main.description).to eq('James Bond novel')

      author = Admin::WikidataLookupEntity.find_by!(qid: 'Q82104')
      expect(author.label).to eq('Ian Fleming')
      expect(labels_fetcher).to have_received(:fetch).with(['Q82104'])
    end

    context 'when referenced Q-IDs are already cached' do
      before { create(:wikidata_lookup_entity, qid: 'Q82104', label: 'Cached') }

      it 'does not refetch them' do
        described_class.cache_from_item!(item, usable_values: usable_values)
        expect(labels_fetcher).not_to have_received(:fetch)
        expect(Admin::WikidataLookupEntity.find_by!(qid: 'Q82104').label).to eq('Cached')
      end
    end
  end

  describe '.enrich' do
    let(:values) do
      {
        'authors' => ['Q82104'],
        'open_library_id' => 'OL85742W',
        'sitelinks' => [{ 'title' => 'The Spy Who Loved Me', 'language' => 'en', 'url' => 'https://en.wikipedia.org' }]
      }
    end

    before { create(:wikidata_lookup_entity, qid: 'Q82104', label: 'Ian Fleming') }

    it 'replaces Q-IDs with id/label hashes and leaves other values alone' do
      expect(described_class.enrich(values)).to eq(
        'authors' => [{ 'id' => 'Q82104', 'label' => 'Ian Fleming' }],
        'open_library_id' => 'OL85742W',
        'sitelinks' => [{ 'title' => 'The Spy Who Loved Me', 'language' => 'en', 'url' => 'https://en.wikipedia.org' }]
      )
    end

    context 'when fetch_missing is true and a label is absent' do
      let(:values) { { 'genres' => ['Q20664331'] } }
      let(:labels_fetcher) { instance_double(Admin::InfoFetchers::Wikidata::Api::EntitiesLabelsFetcher) }

      before do
        allow(Admin::InfoFetchers::Wikidata::Api::EntitiesLabelsFetcher).to receive(:new).and_return(labels_fetcher)
        allow(labels_fetcher).to receive(:fetch).with(['Q20664331']).and_return(
          'Q20664331' => { 'label' => 'spy fiction', 'description' => nil }
        )
      end

      it 'fetches and caches the missing label' do
        expect(described_class.enrich(values, fetch_missing: true)).to eq(
          'genres' => [{ 'id' => 'Q20664331', 'label' => 'spy fiction' }]
        )
        expect(Admin::WikidataLookupEntity.find_by!(qid: 'Q20664331').label).to eq('spy fiction')
      end
    end
  end
end
