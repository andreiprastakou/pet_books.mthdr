require 'rails_helper'

RSpec.describe '/api/series/ref_entries' do
  let(:series) { create(:series, name: 'Foundation') }

  describe 'GET /:id' do
    subject(:send_request) { get "/api/series/ref_entries/#{series.id}.json", headers: authorization_header }

    it 'returns the series ref' do
      send_request
      expect(response).to be_successful
      expect(json_response).to eq(
        id: series.id,
        name: series.name
      )
    end
  end

  describe 'GET /' do
    subject(:send_request) { get '/api/series/ref_entries.json', headers: authorization_header }

    before { series }

    it 'returns list' do
      send_request
      expect(response).to be_successful
      expect(json_response).to eq(
        [{
          id: series.id,
          name: series.name
        }]
      )
    end
  end
end
