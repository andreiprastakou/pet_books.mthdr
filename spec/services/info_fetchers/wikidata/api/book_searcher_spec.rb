require 'rails_helper'

RSpec.describe InfoFetchers::Wikidata::Api::BookSearcher do
  describe '#search' do
    subject(:results) { described_class.new(book).search(**options) }

    let(:options) { {} }
    let(:author) { create(:author, fullname: 'Fyodor Dostoevsky') }
    let(:book) do
      create(:book, title: "Crime and Punishment!", authors: [author], year_published: 1866)
    end

    let(:expected_params) do
      {
        'q' => 'crime and punishment',
        'language' => 'en',
        'limit' => '10'
      }
    end

    let(:service_api_response) do
      {
        'results' => [
          {
            'id' => 'Q165318',
            'display-label' => { 'language' => 'en', 'value' => 'Crime and Punishment' },
            'description' => { 'language' => 'en', 'value' => '1866 novel by Dostoyevsky' }
          },
          {
            'id' => 'Q1978763',
            'display-label' => { 'language' => 'en', 'value' => 'Crime and Punishment' },
            'description' => { 'language' => 'en', 'value' => '1970 film' }
          }
        ]
      }
    end

    before do
      allow(Admin::ExternalApiRateLimit).to receive(:throttle!)
      stub_request(:get, 'https://www.wikidata.org/w/rest.php/wikibase/v1/search/items')
        .with(
          query: expected_params,
          headers: { 'User-Agent' => InfoFetchers::Wikidata::Api::BaseCaller::USER_AGENT }
        )
        .to_return(status: 200, body: service_api_response.to_json)
    end

    it 'queries Wikidata with a simplified title and returns results' do
      expect(results).to eq(service_api_response['results'])
    end

    context 'when title has diacritics and punctuation' do
      let(:book) do
        create(:book, title: 'Cien años de soledad...', authors: [author], year_published: 1967)
      end
      let(:expected_params) do
        {
          'q' => 'cien anos de soledad',
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

    context 'when the title is blank after simplification' do
      let(:book) { build(:book, title: '!!!', authors: [author]) }

      it 'does not call the API and returns an empty array' do
        expect(results).to eq([])
        expect(a_request(:get, %r{wikidata\.org.*/search/items})).not_to have_been_made
      end
    end
  end
end
