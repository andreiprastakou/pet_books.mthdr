require 'rails_helper'

RSpec.describe InfoFetchers::OpenLibrary::Api::AuthorSearcher do
  describe '#search' do
    subject(:results) { described_class.new(author).search(**options) }

    let(:options) { {} }
    let(:author) { create(:author, fullname: 'J. R. R. Tolkien!') }

    let(:expected_params) do
      {
        'q' => 'j r r tolkien',
        'limit' => '10'
      }
    end

    let(:service_api_response) do
      {
        'numFound' => 2,
        'docs' => [
          {
            'key' => 'OL26320A',
            'name' => 'J. R. R. Tolkien',
            'birth_date' => '3 January 1892',
            'top_work' => 'The Lord of the Rings',
            'work_count' => 523
          },
          {
            'key' => 'OL2623360A',
            'name' => 'Christopher Tolkien',
            'birth_date' => '21 November 1924',
            'top_work' => 'The Silmarillion',
            'work_count' => 41
          }
        ]
      }
    end

    before do
      allow(Admin::ExternalApiRateLimit).to receive(:throttle!)
      stub_request(:get, 'https://openlibrary.org/search/authors.json')
        .with(
          query: expected_params,
          headers: { 'User-Agent' => InfoFetchers::OpenLibrary::Api::BaseCaller::USER_AGENT }
        )
        .to_return(status: 200, body: service_api_response.to_json)
    end

    it 'queries Open Library with a simplified name and returns docs' do
      expect(results).to eq(service_api_response['docs'])
    end

    context 'when name has diacritics and punctuation' do
      let(:author) { create(:author, fullname: 'Gabriel García Márquez!') }
      let(:expected_params) do
        {
          'q' => 'gabriel garcia marquez',
          'limit' => '10'
        }
      end

      it 'strips diacritics and punctuation before querying' do
        expect(results).to eq(service_api_response['docs'])
      end
    end

    context 'when a custom limit is provided' do
      let(:options) { { limit: 3 } }
      let(:expected_params) do
        super().merge('limit' => '3')
      end

      it 'passes the limit to the API' do
        expect(results).to eq(service_api_response['docs'])
      end
    end

    context 'when the service returns an error' do
      before do
        stub_request(:get, 'https://openlibrary.org/search/authors.json')
          .with(query: expected_params)
          .to_return(status: 500)
      end

      it 'returns an empty array' do
        expect(results).to eq([])
      end
    end

    context 'when the connection is reset' do
      before do
        stub_request(:get, 'https://openlibrary.org/search/authors.json')
          .with(query: expected_params)
          .to_raise(Errno::ECONNRESET)
      end

      it 'retries then returns an empty array' do
        expect(results).to eq([])
        expect(
          a_request(:get, 'https://openlibrary.org/search/authors.json').with(query: expected_params)
        ).to have_been_made.times(1 + InfoFetchers::OpenLibrary::Api::BaseCaller::MAX_RETRIES)
      end
    end

    context 'when the name is blank after simplification' do
      let(:author) { build(:author, fullname: '!!!') }

      it 'does not call the API and returns an empty array' do
        expect(results).to eq([])
        expect(a_request(:get, 'https://openlibrary.org/search/authors.json')).not_to have_been_made
      end
    end
  end
end
