require 'rails_helper'

RSpec.describe '/api/authors/index_entries' do
  let(:author) { create(:author, birth_year: 1900) }

  before do
    author.books << build(:book, authors: [])
  end

  describe 'GET /:id' do
    subject(:send_request) { get "/api/authors/index_entries/#{author.id}.json", headers: authorization_header }

    it 'returns most basic info' do
      send_request
      expect(response).to be_successful
      expect(response.body).to eq({
        id: author.id,
        fullname: author.fullname,
        books_count: 1,
        thumb_url: nil,
        birth_year: 1900,
        rank: 0
      }.to_json)
    end
  end

  describe 'GET /' do
    subject(:send_request) { get '/api/authors/index_entries.json', headers: authorization_header }

    it 'returns list' do
      send_request
      expect(response).to be_successful
      expect(json_response).to eq(
        total: 1,
        list: [{
          id: author.id,
          fullname: author.fullname,
          books_count: 1,
          thumb_url: nil,
          birth_year: 1900,
          rank: 0
        }]
      )
    end
  end
end
