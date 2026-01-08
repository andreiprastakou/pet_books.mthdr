require 'rails_helper'

RSpec.describe '/api/authors/full_entries' do
  let(:tag) { create(:tag, name: 'foo') }

  before { tag }

  describe 'GET /:id' do
    subject(:send_request) { get "/api/authors/full_entries/#{author.id}.json", headers: authorization_header }

    let(:author) { create(:author, wiki_url: 'https://en.wikipedia.org/wiki/foobar', birth_year: 1900, death_year: 2000, tags: [tag]) }
    let(:expected_response) do
      {
        id: author.id,
        fullname: author.fullname,
        photo_thumb_url: nil,
        photo_full_url: nil,
        reference: 'https://en.wikipedia.org/wiki/foobar',
        birth_year: 1900,
        death_year: 2000,
        tag_ids: [tag.id],
        books_count: 1,
        popularity: 10_000,
        rank: 0
      }
    end

    before do
      author.books << build(:book, authors: [], popularity: 10_000)
    end

    it 'returns full info' do
      send_request
      expect(response).to be_successful
      expect(response.body).to eq(expected_response.to_json)
    end
  end
end
