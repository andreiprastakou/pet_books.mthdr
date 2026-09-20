require 'rails_helper'

RSpec.describe '/api/authors/full_entries' do
  let(:tag) { create(:tag, name: 'foo') }

  before { tag }

  describe 'GET /:id' do
    subject(:send_request) { get "/api/authors/full_entries/#{author.id}.json", headers: authorization_header }

    let(:author) do
      create(
        :author,
        wiki_url: 'https://en.wikipedia.org/wiki/foobar',
        birth_year: 1900,
        death_year: 2000,
        tags: [tag]
      )
    end
    let(:expected_response) do
      {
        id: author.id,
        fullname: author.fullname,
        photo_thumb_url: nil,
        photo_full_url: nil,
        external_links: [{
          external_resource: ExternalResources::WIKIPEDIA,
          label: 'Wikipedia',
          url: 'https://en.wikipedia.org/wiki/foobar'
        }],
        birth_year: 1900,
        death_year: 2000,
        tag_ids: [tag.id],
        books_count: 1,
        popularity: 10_000,
        rank: 0
      }
    end

    before do
      create(
        :external_link,
        owner: author,
        external_resource: ExternalResources::WIKIDATA,
        url: 'https://www.wikidata.org/wiki/Q1'
      )
      author.books << build(:book, authors: [], popularity: 10_000)
    end

    it 'returns full info' do
      send_request
      expect(response).to be_successful
      expect(response.body).to eq(expected_response.to_json)
    end
  end
end
