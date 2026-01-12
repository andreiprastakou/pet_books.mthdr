require 'rails_helper'

RSpec.describe '/api/tags/index_entries' do
  let(:tag) { create(:tag, category: 'other') }

  before { create(:tag_connection, tag: tag, entity: build(:book)) }

  describe 'GET /:id' do
    subject(:send_request) { get "/api/tags/index_entries/#{tag.id}.json", headers: authorization_header }

    it 'returns list' do
      send_request
      expect(response).to be_successful
      expect(json_response).to eq(
        id: tag.id,
        name: tag.name,
        book_connections_count: 1,
        author_connections_count: 0,
        category_id: 0
      )
    end
  end

  describe 'GET /' do
    subject(:send_request) { get '/api/tags/index_entries.json', headers: authorization_header }

    it 'returns list' do
      send_request
      expect(response).to be_successful
      expect(json_response).to eq(
        [{
          id: tag.id,
          name: tag.name,
          book_connections_count: 1,
          author_connections_count: 0,
          category_id: 0
        }]
      )
    end
  end
end
