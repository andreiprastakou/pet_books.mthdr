require 'rails_helper'

RSpec.describe Admin::InfoFetchers::OpenLibrary::Api::BookSearcher do
  describe '#search' do
    subject(:results) { described_class.new(book).search(**options) }

    let(:options) { {} }
    let(:author) { create(:author, fullname: 'Fyodor Dostoevsky') }
    let(:book) do
      create(:book, title: 'Crime and Punishment!', authors: [author], year_published: 1866)
    end

    let(:expected_params) do
      {
        'title' => 'crime and punishment',
        'author' => 'fyodor dostoevsky',
        'fields' => described_class::DEFAULT_FIELDS.join(','),
        'limit' => '10'
      }
    end

    let(:service_api_response) do
      {
        'numFound' => 2,
        'docs' => [
          {
            'key' => '/works/OL166894W',
            'title' => 'Crime and Punishment',
            'author_name' => ['Fyodor Dostoyevsky'],
            'first_publish_year' => 1866,
            'edition_count' => 290
          },
          {
            'key' => '/works/OL999W',
            'title' => 'Crime and Punishment (adaptation)',
            'author_name' => ['Someone Else'],
            'first_publish_year' => 2001
          }
        ]
      }
    end

    before do
      allow(Admin::ExternalApiRateLimit).to receive(:throttle!)
      stub_request(:get, 'https://openlibrary.org/search.json')
        .with(
          query: expected_params,
          headers: { 'User-Agent' => Admin::InfoFetchers::OpenLibrary::Api::BaseCaller::USER_AGENT }
        )
        .to_return(status: 200, body: service_api_response.to_json)
    end

    it 'queries Open Library with simplified title and authors and returns docs' do
      expect(results).to eq(service_api_response['docs'])
    end

    context 'when title has diacritics and punctuation' do
      let(:author) { create(:author, fullname: 'Gabriel García Márquez!') }
      let(:book) do
        create(:book, title: 'Cien años de soledad...', authors: [author], year_published: 1967)
      end
      let(:expected_params) do
        {
          'title' => 'cien anos de soledad',
          'author' => 'gabriel garcia marquez',
          'fields' => described_class::DEFAULT_FIELDS.join(','),
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

    context 'when the book has no authors' do
      let(:book) { create(:book, title: 'Anonymous Work', authors: [], year_published: 1900) }
      let(:expected_params) do
        {
          'title' => 'anonymous work',
          'fields' => described_class::DEFAULT_FIELDS.join(','),
          'limit' => '10'
        }
      end

      it 'queries by title only' do
        expect(results).to eq(service_api_response['docs'])
      end
    end

    context 'when the service returns an error' do
      before do
        stub_request(:get, 'https://openlibrary.org/search.json')
          .with(query: expected_params)
          .to_return(status: 500)
      end

      it 'returns an empty array' do
        expect(results).to eq([])
      end
    end

    context 'when the connection is reset' do
      before do
        stub_request(:get, 'https://openlibrary.org/search.json')
          .with(query: expected_params)
          .to_raise(Errno::ECONNRESET)
      end

      it 'retries then returns an empty array' do
        expect(results).to eq([])
        expect(
          a_request(:get, 'https://openlibrary.org/search.json').with(query: expected_params)
        ).to have_been_made.times(1 + Admin::InfoFetchers::OpenLibrary::Api::BaseCaller::MAX_RETRIES)
      end
    end

    context 'when the title is blank after simplification' do
      let(:book) { build(:book, title: '!!!', authors: [author]) }

      it 'does not call the API and returns an empty array' do
        expect(results).to eq([])
        expect(a_request(:get, 'https://openlibrary.org/search.json')).not_to have_been_made
      end
    end
  end
end
