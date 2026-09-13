require 'rails_helper'

RSpec.describe InfoFetchers::Wikidata::Api::AuthorDetailsFetcher do
  describe '#fetch' do
    subject(:result) { described_class.new(entity_id).fetch }

    let(:entity_id) { 'Q892' }
    let(:expected_url) do
      'https://www.wikidata.org/w/rest.php/wikibase/v1/entities/items/Q892'
    end
    let(:service_api_response) do
      {
        'type' => 'item',
        'id' => 'Q892',
        'labels' => { 'en' => 'J. R. R. Tolkien' },
        'descriptions' => { 'en' => 'English writer and philologist (1892–1973)' },
        'statements' => {},
        'sitelinks' => {}
      }
    end

    before do
      allow(ExternalApiRateLimit).to receive(:throttle!)
      stub_request(:get, expected_url)
        .with(headers: { 'User-Agent' => InfoFetchers::Wikidata::Api::BaseCaller::USER_AGENT })
        .to_return(status: 200, body: service_api_response.to_json)
    end

    it 'fetches the item JSON for the given Q-ID' do
      expect(result).to eq(service_api_response)
    end

    context 'when given a wiki path' do
      let(:entity_id) { '/wiki/Q892' }

      it 'normalizes and fetches the item' do
        expect(result).to eq(service_api_response)
      end
    end

    context 'when given a full URL' do
      let(:entity_id) { 'https://www.wikidata.org/wiki/Q892' }

      it 'normalizes and fetches the item' do
        expect(result).to eq(service_api_response)
      end
    end

    context 'when the id is blank' do
      let(:entity_id) { '  ' }

      it 'does not call the API and returns nil' do
        expect(result).to be_nil
        expect(a_request(:get, %r{wikidata\.org})).not_to have_been_made
      end
    end

    context 'when the id is invalid' do
      let(:entity_id) { 'not-a-qid' }

      it 'does not call the API and returns nil' do
        expect(result).to be_nil
        expect(a_request(:get, %r{wikidata\.org})).not_to have_been_made
      end
    end

    context 'when the service returns an error' do
      before do
        stub_request(:get, expected_url).to_return(status: 404)
      end

      it 'returns nil' do
        expect(result).to be_nil
      end
    end
  end
end
