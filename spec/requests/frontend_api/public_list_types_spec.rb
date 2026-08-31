require 'rails_helper'

RSpec.describe '/api/public_list_types' do
  describe 'GET /' do
    subject(:send_request) { get '/api/public_list_types.json', headers: authorization_header }

    let!(:second_type) { create(:public_list_type, name: 'Zines') }
    let!(:first_type) { create(:public_list_type, name: 'Awards') }

    it 'returns public list types ordered by name' do
      send_request

      expect(response).to be_successful
      expect(json_response).to eq([
        { id: first_type.id, name: 'Awards' },
        { id: second_type.id, name: 'Zines' },
      ])
    end
  end

  describe 'GET /:id' do
    subject(:send_request) do
      get "/api/public_list_types/#{list_type.id}.json", headers: authorization_header
    end

    let(:list_type) do
      create(:public_list_type, name: 'Awards', wiki_url: 'https://en.wikipedia.org/wiki/Awards')
    end
    let!(:older_list) { create(:public_list, public_list_type: list_type, year: 2020) }
    let!(:newer_list) { create(:public_list, public_list_type: list_type, year: 2021) }
    let(:book) { create(:book) }

    before { newer_list.books << book }

    it 'returns lists and their book ids' do
      send_request

      expect(response).to be_successful
      expect(json_response).to include(
        id: list_type.id,
        name: 'Awards',
        wiki_url: 'https://en.wikipedia.org/wiki/Awards',
        public_lists: [
          { id: newer_list.id, year: 2021, wiki_url: nil, generic_links: [], book_ids: [book.id] },
          { id: older_list.id, year: 2020, wiki_url: nil, generic_links: [], book_ids: [] },
        ]
      )
    end
  end
end
