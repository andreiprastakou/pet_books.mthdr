require 'rails_helper'

RSpec.describe '/api/books/ref_entries' do
  describe 'GET /:id' do
    subject(:send_request) { get "/api/books/ref_entries/#{book.id}.json", headers: authorization_header }

    let(:book) { create(:book, year_published: 2000) }

    it 'returns book info' do
      send_request

      expect(response).to be_successful
      expect(json_response).to eq(
        id: book.id,
        author_ids: book.author_ids,
        year: 2000
      )
    end
  end

  describe 'GET /' do
    subject(:send_request) { get '/api/books/ref_entries.json', headers: authorization_header }

    let(:book) { create(:book) }

    before { book }

    it 'returns books page and their total number' do
      send_request

      expect(response).to be_successful
      expect(json_response).to match(list: [hash_including(id: book.id)], total: 1)
    end
  end
end
