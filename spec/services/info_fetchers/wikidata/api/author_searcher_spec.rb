require 'rails_helper'

RSpec.describe InfoFetchers::Wikidata::Api::AuthorSearcher do
  describe '#search' do
    subject(:results) { described_class.new(author).search(**options) }

    let(:options) { {} }
    let(:author) { create(:author, fullname: 'J. R. R. Tolkien!') }

    let(:expected_params) do
      {
        'q' => 'j r r tolkien',
        'language' => 'en',
        'limit' => '10'
      }
    end

    let(:service_api_response) do
      {
        'results' => [
          {
            'id' => 'Q892',
            'display-label' => { 'language' => 'en', 'value' => 'J. R. R. Tolkien' },
            'description' => { 'language' => 'en', 'value' => 'English writer and philologist' }
          },
          {
            'id' => 'Q81738',
            'display-label' => { 'language' => 'en', 'value' => "Tolkien's legendarium" },
            'description' => { 'language' => 'en', 'value' => 'fictional universe' }
          }
        ]
      }
    end

    before do
      allow(ExternalApiRateLimit).to receive(:throttle!)
      stub_request(:get, 'https://www.wikidata.org/w/rest.php/wikibase/v1/search/items')
        .with(
          query: expected_params,
          headers: { 'User-Agent' => InfoFetchers::Wikidata::Api::BaseCaller::USER_AGENT }
        )
        .to_return(status: 200, body: service_api_response.to_json)
    end

    it 'queries Wikidata with a simplified name and returns results' do
      expect(results).to eq(service_api_response['results'])
    end

    context 'when name has diacritics and punctuation' do
      let(:author) { create(:author, fullname: 'Gabriel García Márquez!') }
      let(:expected_params) do
        {
          'q' => 'gabriel garcia marquez',
          'language' => 'en',
          'limit' => '10'
        }
      end

      it 'strips diacritics and punctuation before querying' do
        expect(results).to eq(service_api_response['results'])
      end
    end

    context 'when a custom limit is provided' do
      let(:options) { { limit: 3 } }
      let(:expected_params) do
        super().merge('limit' => '3')
      end

      it 'passes the limit to the API' do
        expect(results).to eq(service_api_response['results'])
      end
    end

    context 'when the service returns an error' do
      before do
        stub_request(:get, 'https://www.wikidata.org/w/rest.php/wikibase/v1/search/items')
          .with(query: expected_params)
          .to_return(status: 500)
      end

      it 'returns an empty array' do
        expect(results).to eq([])
      end
    end

    context 'when the name is blank after simplification' do
      let(:author) { build(:author, fullname: '!!!') }

      it 'does not call the API and returns an empty array' do
        expect(results).to eq([])
        expect(a_request(:get, %r{wikidata\.org.*/search/items})).not_to have_been_made
      end
    end
  end
end
