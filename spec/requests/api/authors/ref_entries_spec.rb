require 'rails_helper'

RSpec.describe '/api/authors/ref_entries' do
  let(:author) { create(:author) }

  before { author.books << build(:book, authors: []) }

  describe 'GET /:id' do
    subject(:send_request) { get "/api/authors/ref_entries/#{author.id}.json", headers: authorization_header }

    it 'returns most basic info' do
      send_request
      expect(response).to be_successful
      expect(response.body).to eq({
        id: author.id,
        fullname: author.fullname
      }.to_json)
    end
  end

  describe 'GET /' do
    subject(:send_request) { get '/api/authors/ref_entries.json', headers: authorization_header }

    it 'returns list' do
      send_request
      expect(response).to be_successful
      expect(response.body).to eq([{
        id: author.id,
        fullname: author.fullname
      }].to_json)
    end
  end
end
