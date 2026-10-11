# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/books/reads' do
  let(:reader) { create(:user) }
  let(:book) { create(:book) }

  before { sign_in_frontend_user!(reader) }

  describe 'PUT /:id' do
    subject(:send_request) { put "/api/books/reads/#{book.id}.json" }

    it 'marks the book read for the current user' do
      send_request

      expect(response).to be_successful
      expect(json_response).to eq(book_id: book.id, read: true)
      expect(UserBookRead.exists?(user: reader, book: book)).to be(true)
    end

    it 'does not create a second row when the book is already read' do
      create(:user_book_read, user: reader, book: book)

      send_request

      expect(response).to be_successful
      expect(UserBookRead.where(user: reader, book: book).count).to eq(1)
    end

    it 'returns not found for an unknown book' do
      put '/api/books/reads/0.json'

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /:id' do
    subject(:send_request) { delete "/api/books/reads/#{book.id}.json" }

    it 'unmarks the book for the current user and leaves other readers intact' do
      other_reader = create(:user)
      create(:user_book_read, user: reader, book: book)
      create(:user_book_read, user: other_reader, book: book)

      send_request

      expect(response).to be_successful
      expect(json_response).to eq(book_id: book.id, read: false)
      expect(UserBookRead.exists?(user: reader, book: book)).to be(false)
      expect(UserBookRead.exists?(user: other_reader, book: book)).to be(true)
    end

    it 'succeeds when the book was not marked read' do
      send_request

      expect(response).to be_successful
      expect(json_response).to eq(book_id: book.id, read: false)
    end
  end
end
