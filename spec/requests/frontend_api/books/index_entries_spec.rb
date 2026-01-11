require 'rails_helper'

RSpec.describe '/api/books/index_entries' do
  before { default_cover_design }

  let(:default_cover_design) { create(:cover_design, :default) }

  describe 'GET /:id' do
    subject(:send_request) { get "/api/books/index_entries/#{book.id}.json", headers: authorization_header }

    let(:book) do
      create(:book, year_published: 2000, popularity: 20_000, tags: [tag])
    end
    let(:tag) { create(:tag) }

    it 'returns book info' do
      send_request

      expect(response).to be_successful
      expect(response.body).to eq({
        id: book.id,
        title: book.title,
        cover_thumb_url: nil,
        cover_full_url: nil,
        author_ids: book.author_ids,
        year: 2000,
        tag_ids: [tag.id],
        popularity: 20_000,
        global_rank: 0,
        cover_design_id: default_cover_design.id
      }.to_json)
    end
  end

  describe 'GET /' do
    subject(:send_request) { get '/api/books/index_entries.json', params: params, headers: authorization_header }

    let(:params) { { ids: [book.id] } }
    let(:book) do
      create(:book, year_published: 2000, popularity: 20_000, tags: [tag])
    end
    let(:tag) { create(:tag) }

    before { book }

    it 'returns books page and their total number' do
      send_request

      expect(response).to be_successful
      expect(response.body).to eq([{
        id: book.id,
        title: book.title,
        cover_thumb_url: nil,
        author_ids: book.author_ids,
        year: 2000,
        tag_ids: [tag.id],
        popularity: 20_000,
        global_rank: 0,
        cover_design_id: default_cover_design.id
      }].to_json)
    end
  end
end
