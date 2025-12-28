require 'rails_helper'

RSpec.describe '/api/books/full_entries' do
  describe 'GET /:id' do
    subject(:send_request) { get "/api/books/full_entries/#{book.id}.json", headers: authorization_header }

    let(:book) { create(:book, tags: tags) }
    let(:tags) { create_list(:tag, 2) }

    it 'renders the book' do
      book
      send_request

      expect(response).to be_successful
      expect(json_response).to eq(
        id: book.id,
        title: book.title,
        original_title: book.original_title,
        author_id: book.author_ids.first,
        tag_ids: tags.map(&:id),
        year_published: book.year_published,
        cover_thumb_url: nil,
        goodreads_url: nil
      )
    end
  end

  describe 'POST /' do
    subject(:send_request) do
      post '/api/books/full_entries.json', params: { book: book_params }, headers: authorization_header
    end

    let(:book_params) { { title: 'NEW_BOOK', author_ids: [author.id], year_published: 1900 } }
    let(:author) { create(:author) }

    it 'creates a book', :aggregate_failures do
      expect { send_request }.to change(Book, :count).by(1)

      book = Book.last
      expect(response).to be_successful
      expect(json_response).to eq(id: book.id)
      expect(book.title).to eq('NEW_BOOK')
      expect(book.author_ids).to eq([author.id])
      expect(book.year_published).to eq(1900)
    end
  end

  describe 'PUT /:id' do
    subject(:send_request) do
      put "/api/books/full_entries/#{book.id}.json", params: { book: book_params }, headers: authorization_header
    end

    let(:book) { create(:book, title: 'OLD_TITLE') }
    let(:book_params) { { title: 'NEW_TITLE' } }

    it 'updates the book' do
      send_request

      expect(response).to be_successful
      expect(book.reload.title).to eq('NEW_TITLE')
    end
  end

  describe 'DELETE /:id' do
    subject(:send_request) do
      delete "/api/books/full_entries/#{book.id}.json", headers: authorization_header
    end

    let(:book) { create(:book) }

    it 'deletes the book' do
      book
      expect { send_request }.to change(Book, :count).by(-1)

      expect(response).to be_successful
    end
  end
end
