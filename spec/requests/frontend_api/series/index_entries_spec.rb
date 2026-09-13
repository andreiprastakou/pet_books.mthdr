require 'rails_helper'

RSpec.describe '/api/series/index_entries' do
  let(:series) do
    create(
      :series,
      external_links: external_links,
      name: 'Earthsea',
      wiki_url: 'https://en.wikipedia.org/wiki/Earthsea'
    )
  end
  let(:external_links) { build_list(:external_link, 1) }

  describe 'GET /:id' do
    subject(:send_request) { get "/api/series/index_entries/#{series.id}.json", headers: authorization_header }

    it 'returns the series with links' do
      send_request
      expect(response).to be_successful
      expect(json_response).to eq(
        id: series.id,
        name: series.name,
        wiki_url: series.wiki_url,
        external_links: external_links.map { |link| { external_resource: link.external_resource, url: link.url } }
      )
    end
  end

  describe 'GET /' do
    subject(:send_request) { get '/api/series/index_entries.json', headers: authorization_header }

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
