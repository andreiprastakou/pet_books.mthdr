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
        author_ids: book.author_ids,
        year: 2000,
        tag_ids: [tag.id],
        popularity: 20_000,
        global_rank: 0,
        cover_design_id: default_cover_design.id,
        format: 'normal'
      }.to_json)
    end

    context 'when the book is a collection' do
      let(:older_work) { create(:book, title: 'Older Work', year_published: 1990) }
      let(:newer_work) { create(:book, title: 'Newer Work', year_published: 2010) }

      before do
        book.update!(literary_form: 'collection')
        create(:book_collection, collection: book, book: older_work)
        create(:book_collection, collection: book, book: newer_work)
      end

      it 'returns collected work ids newest first' do
        send_request

        expect(json_response[:collected_work_ids]).to eq([newer_work.id, older_work.id])
      end
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
        author_ids: book.author_ids,
        year: 2000,
        tag_ids: [tag.id],
        popularity: 20_000,
        global_rank: 0,
        cover_design_id: default_cover_design.id,
        format: 'normal'
      }].to_json)
    end

    context 'when a book is a collection' do
      let(:older_work) { create(:book, title: 'Older Work', year_published: 1990) }
      let(:newer_work) { create(:book, title: 'Newer Work', year_published: 2010) }
      let(:params) { { ids: [book.id, newer_work.id] } }

      before do
        book.update!(literary_form: 'collection')
        create(:book_collection, collection: book, book: older_work)
        create(:book_collection, collection: book, book: newer_work)
      end

      it 'returns collected work ids on collection books only' do
        send_request

        collection = json_response.find { |entry| entry[:id] == book.id }
        work = json_response.find { |entry| entry[:id] == newer_work.id }
        expect(collection[:collected_work_ids]).to eq([newer_work.id, older_work.id])
        expect(work).not_to have_key(:collected_work_ids)
      end
    end
  end
end
