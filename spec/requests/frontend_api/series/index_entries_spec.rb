require 'rails_helper'

RSpec.describe '/api/series/index_entries' do
  let(:series) do
    create(
      :series,
      external_links: external_links,
      name: 'Earthsea'
    )
  end
  let(:wikipedia_link) do
    build(:external_link, external_resource: ExternalResources::WIKIPEDIA,
                          url: 'https://en.wikipedia.org/wiki/Earthsea')
  end
  let(:wikidata_link) do
    build(:external_link, external_resource: ExternalResources::WIKIDATA,
                          url: 'https://www.wikidata.org/wiki/Q1')
  end
  let(:other_links) { build_list(:external_link, 1) }
  let(:external_links) { [wikipedia_link, wikidata_link] + other_links }
  let(:frontend_external_links) { [wikipedia_link] + other_links }

  describe 'GET /:id' do
    subject(:send_request) { get "/api/series/index_entries/#{series.id}.json", headers: authorization_header }

    it 'returns the series with links' do
      send_request
      expect(response).to be_successful
      expect(json_response).to eq(
        id: series.id,
        name: series.name,
        external_links: frontend_external_links.map { |link|
          {
            external_resource: link.external_resource,
            label: ExternalResources.label_for(link.external_resource),
            url: link.url
          }
        }
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
