require 'rails_helper'

RSpec.describe InfoFetchers::OpenLibrary::BookDetails do
  describe '#fetch' do
    subject(:result) { described_class.new(work_key).fetch }

    let(:work_key) { '/works/OL27448W' }
    let(:expected_url) { 'https://openlibrary.org/works/OL27448W.json' }
    let(:service_api_response) do
      {
        'key' => '/works/OL27448W',
        'title' => 'The Lord of the Rings',
        'authors' => [{ 'author' => { 'key' => '/authors/OL26320A' } }],
        'description' => {
          'type' => '/type/text',
          'value' => 'An epic fantasy novel.'
        },
        'covers' => [12_345],
        'subjects' => %w[Fantasy Fiction],
        'first_publish_date' => '1954'
      }
    end

    before do
      stub_request(:get, expected_url)
        .with(headers: { 'User-Agent' => InfoFetchers::OpenLibrary::BaseFetcher::USER_AGENT })
        .to_return(status: 200, body: service_api_response.to_json)
    end

    it 'fetches the work JSON for the given key' do
      expect(result).to eq(service_api_response)
    end

    context 'when given a bare OLID' do
      let(:work_key) { 'OL27448W' }

      it 'normalizes and fetches the work' do
        expect(result).to eq(service_api_response)
      end
    end

    context 'when given a key with .json suffix' do
      let(:work_key) { '/works/OL27448W.json' }

      it 'normalizes and fetches the work' do
        expect(result).to eq(service_api_response)
      end
    end

    context 'when the key is blank' do
      let(:work_key) { '  ' }

      it 'does not call the API and returns nil' do
        expect(result).to be_nil
        expect(a_request(:get, %r{openlibrary\.org/works/})).not_to have_been_made
      end
    end

    context 'when the key is invalid' do
      let(:work_key) { 'not-a-work-key' }

      it 'does not call the API and returns nil' do
        expect(result).to be_nil
        expect(a_request(:get, %r{openlibrary\.org/works/})).not_to have_been_made
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
