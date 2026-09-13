require 'rails_helper'

RSpec.describe InfoFetchers::Wikidata::BookExternalDataFetcher do
  describe '#fetch!' do
    subject(:result) { described_class.new(external_identity).fetch! }

    let(:book) { create(:book) }
    let(:external_identity) do
      create(:external_identity, owner: book, external_resource: :wikidata, identificator: 'Q74287')
    end
    let(:api_response) do
      {
        'id' => 'Q74287',
        'labels' => { 'en' => 'The Hobbit' },
        'descriptions' => { 'en' => '1937 novel by J. R. R. Tolkien' }
      }
    end
    let(:details_fetcher) { instance_double(InfoFetchers::Wikidata::Api::BookDetailsFetcher) }

    before do
      allow(InfoFetchers::Wikidata::Api::BookDetailsFetcher)
        .to receive(:new).with('Q74287').and_return(details_fetcher)
      allow(details_fetcher).to receive(:fetch).and_return(api_response)
    end

    it 'saves the API response as an ExternalDataFetch' do
      expect { result }.to change(external_identity.external_data_fetches, :count).by(1)
      expect(result).to be_a(ExternalDataFetch)
      expect(result.data).to eq(api_response)
      expect(result.external_identity).to eq(external_identity)
    end

    context 'when the API returns nil' do
      before { allow(details_fetcher).to receive(:fetch).and_return(nil) }

      it 'does not create an ExternalDataFetch' do
        expect { result }.not_to change(ExternalDataFetch, :count)
        expect(result).to be_nil
      end
    end
  end
end
