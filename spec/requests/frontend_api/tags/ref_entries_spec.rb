require 'rails_helper'

RSpec.describe '/api/tags/ref_entries' do
  let(:tag) { create(:tag) }

  before { create(:tag_connection, tag: tag, entity: build(:book)) }

  describe 'GET /:id' do
    subject(:send_request) { get "/api/tags/ref_entries/#{tag.id}.json", headers: authorization_header }

    it 'returns list' do
      send_request
      expect(response).to be_successful
      expect(json_response).to eq(
        id: tag.id,
        name: tag.name,
        category_id: 0,
        connections_count: 1
      )
    end
  end

  describe 'GET /' do
    subject(:send_request) { get '/api/tags/ref_entries.json', headers: authorization_header }

    it 'returns list' do
      send_request
      expect(response).to be_successful
      expect(json_response).to eq(
        [{
          id: tag.id,
          name: tag.name,
          category_id: 0,
          connections_count: 1
        }]
      )
    end
  end
end
