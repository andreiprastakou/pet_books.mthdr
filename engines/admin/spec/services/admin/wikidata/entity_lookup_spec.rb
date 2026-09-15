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
    let(:data) do
      {
        'authors' => ['Q82104'],
        'external_identities' => [
          { 'external_resource' => 'open_library', 'external_id' => 'OL85742W' }
        ]
      }
    end
    let(:labels_fetcher) { instance_double(Admin::InfoFetchers::Wikidata::Api::EntitiesLabelsFetcher) }

    before do
      allow(Admin::InfoFetchers::Wikidata::Api::EntitiesLabelsFetcher).to receive(:new).and_return(labels_fetcher)
      allow(labels_fetcher).to receive(:fetch).with(['Q82104']).and_return(
        'Q82104' => { 'label' => 'Ian Fleming', 'description' => 'English author' }
      )
    end

    it 'upserts the main item and referenced Q-IDs' do
      expect { described_class.cache_from_item!(item, data: data) }
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
        described_class.cache_from_item!(item, data: data)
        expect(labels_fetcher).not_to have_received(:fetch)
        expect(Admin::WikidataLookupEntity.find_by!(qid: 'Q82104').label).to eq('Cached')
      end
    end
  end

  describe '.enrich' do
    let(:values) do
      {
        'authors' => ['Q82104'],
        'genres' => ['Q20664331'],
        'external_identities' => [
          { 'external_resource' => 'open_library', 'external_id' => 'OL85742W' }
        ],
        'sitelinks' => [{ 'title' => 'The Spy Who Loved Me', 'language' => 'en', 'url' => 'https://en.wikipedia.org' }]
      }
    end

    before do
      create(:wikidata_lookup_entity, qid: 'Q82104', label: 'Ian Fleming')
      create(:wikidata_lookup_entity, qid: 'Q20664331', label: 'spy fiction')
    end

    it 'replaces Q-IDs with external_id hashes and leaves other values alone' do
      expect(described_class.enrich(values)).to eq(
        'authors' => [{ 'external_id' => 'Q82104', 'name' => 'Ian Fleming' }],
        'genres' => [{ 'external_id' => 'Q20664331', 'label' => 'spy fiction' }],
        'external_identities' => [
          { 'external_resource' => 'open_library', 'external_id' => 'OL85742W' }
        ],
        'sitelinks' => [{ 'title' => 'The Spy Who Loved Me', 'language' => 'en', 'url' => 'https://en.wikipedia.org' }]
      )
    end

    context 'when fetch_missing is true and a label is absent' do
      let(:values) { { 'genres' => ['Q20664331'] } }
      let(:labels_fetcher) { instance_double(Admin::InfoFetchers::Wikidata::Api::EntitiesLabelsFetcher) }

      before do
        Admin::WikidataLookupEntity.where(qid: 'Q20664331').delete_all
        allow(Admin::InfoFetchers::Wikidata::Api::EntitiesLabelsFetcher).to receive(:new).and_return(labels_fetcher)
        allow(labels_fetcher).to receive(:fetch).with(['Q20664331']).and_return(
          'Q20664331' => { 'label' => 'spy fiction', 'description' => nil }
        )
      end

      it 'fetches and caches the missing label' do
        expect(described_class.enrich(values, fetch_missing: true)).to eq(
          'genres' => [{ 'external_id' => 'Q20664331', 'label' => 'spy fiction' }]
        )
        expect(Admin::WikidataLookupEntity.find_by!(qid: 'Q20664331').label).to eq('spy fiction')
      end
    end

    context 'with enriched book fixture values' do
      let(:fetched_data) do
        JSON.parse(
          File.read(
            Rails.root.join(
              'engines/admin/spec/fixtures/wikidata/book_fetch_tailored_realities.json'
            )
          )
        )
      end
      let(:values) { Admin::Wikidata::BookUsableValues.call(fetched_data) }

      before do
        create(:wikidata_lookup_entity, qid: 'Q457608', label: 'Brandon Sanderson')
        create(:wikidata_lookup_entity, qid: 'Q132311', label: 'fantasy')
        create(:wikidata_lookup_entity, qid: 'Q24925', label: 'science fiction')
        create(:wikidata_lookup_entity, qid: 'Q30', label: 'United States')
      end

      it 'matches the book usable-values display format' do
        expect(described_class.enrich(values)).to eq(
          'authors' => [
            { 'external_id' => 'Q457608', 'name' => 'Brandon Sanderson' }
          ],
          'external_identities' => [
            { 'external_resource' => 'open_library', 'external_id' => 'OL42413123W' },
            { 'external_resource' => 'librarything', 'external_id' => '33363109' },
            { 'external_resource' => 'goodreads', 'external_id' => '87596585' }
          ],
          'publication_date' => '2025-12-09',
          'genres' => [
            { 'external_id' => 'Q132311', 'label' => 'fantasy' },
            { 'external_id' => 'Q24925', 'label' => 'science fiction' }
          ],
          'country_of_origin' => [
            { 'external_id' => 'Q30', 'label' => 'United States' }
          ]
        )
      end
    end

    context 'with enriched author fixture values' do
      let(:fetched_data) do
        JSON.parse(
          File.read(
            Rails.root.join(
              'engines/admin/spec/fixtures/wikidata/author_fetch_robert_jordan.json'
            )
          )
        )
      end
      let(:values) { Admin::Wikidata::AuthorUsableValues.call(fetched_data) }
      let(:enriched) { described_class.enrich(values) }

      before do
        create(:wikidata_lookup_entity, qid: 'Q30', label: 'United States')
        create(:wikidata_lookup_entity, qid: 'Q1860', label: 'English')
        create(:wikidata_lookup_entity, qid: 'Q1754110', label: 'Distinguished Flying Cross')
        create(:wikidata_lookup_entity, qid: 'Q928314', label: 'Bronze Star Medal')
        create(:wikidata_lookup_entity, qid: 'Q2687578', label: 'Inkpot Award')
      end

      it 'matches the author usable-values display format' do
        expect(enriched.except('sitelinks')).to eq(
          'name' => 'Robert Jordan',
          'date_of_birth' => '1948-10-17',
          'date_of_death' => '2007-09-16',
          'image' => 'Robert Jordan.jpg',
          'countries' => [
            { 'external_id' => 'Q30', 'label' => 'United States' }
          ],
          'languages' => [
            { 'external_id' => 'Q1860', 'label' => 'English' }
          ],
          'awards' => [
            { 'external_id' => 'Q1754110', 'label' => 'Distinguished Flying Cross' },
            { 'external_id' => 'Q928314', 'label' => 'Bronze Star Medal' },
            { 'external_id' => 'Q2687578', 'label' => 'Inkpot Award' }
          ],
          'external_identities' => [
            { 'external_resource' => 'open_library', 'external_id' => 'OL233594A' },
            { 'external_resource' => 'goodreads', 'external_id' => '6252' },
            { 'external_resource' => 'librarything', 'external_id' => 'jordanrobert-1' }
          ]
        )
        expect(enriched['sitelinks'].size).to eq(44)
        expect(enriched['sitelinks'].first).to eq(
          'title' => 'Robert Jordan',
          'language' => 'en',
          'url' => 'https://en.wikipedia.org/wiki/Robert_Jordan'
        )
      end
    end
  end
end
