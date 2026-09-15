require 'rails_helper'

RSpec.describe Admin::InfoFetchers::OpenLibrary::Api::AuthorDetailsFetcher do
  describe '#fetch' do
    subject(:result) { described_class.new(author_key).fetch }

    let(:author_key) { '/authors/OL1394865A' }
    let(:expected_url) { 'https://openlibrary.org/authors/OL1394865A.json' }
    let(:service_api_response) do
      {
        'key' => '/authors/OL1394865A',
        'name' => 'J. R. R. Tolkien',
        'birth_date' => '3 January 1892',
        'death_date' => '2 September 1973',
        'photos' => [6_657_685]
      }
    end

    before do
      allow(Admin::ExternalApiRateLimit).to receive(:throttle!)
      stub_request(:get, expected_url)
        .with(headers: { 'User-Agent' => Admin::InfoFetchers::OpenLibrary::Api::BaseCaller::USER_AGENT })
        .to_return(status: 200, body: service_api_response.to_json)
    end

    it 'fetches the author JSON for the given key' do
      expect(result).to eq(service_api_response)
    end

    context 'when given a bare OLID' do
      let(:author_key) { 'OL1394865A' }

      it 'normalizes and fetches the author' do
        expect(result).to eq(service_api_response)
      end
    end

    context 'when given a key with .json suffix' do
      let(:author_key) { '/authors/OL1394865A.json' }

      it 'normalizes and fetches the author' do
        expect(result).to eq(service_api_response)
      end
    end

    context 'when the key is blank' do
      let(:author_key) { '  ' }

      it 'does not call the API and returns nil' do
        expect(result).to be_nil
        expect(a_request(:get, %r{openlibrary\.org/authors/})).not_to have_been_made
      end
    end

    context 'when the key is invalid' do
      let(:author_key) { 'not-an-author-key' }

      it 'does not call the API and returns nil' do
        expect(result).to be_nil
        expect(a_request(:get, %r{openlibrary\.org/authors/})).not_to have_been_made
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
