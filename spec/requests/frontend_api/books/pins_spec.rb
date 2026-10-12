# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/books/pins' do
  let(:reader) { create(:user) }
  let(:book) { create(:book) }

  before { sign_in_frontend_user!(reader) }

  describe 'PUT /:id' do
    subject(:send_request) { put "/api/books/pins/#{book.id}.json" }

    it 'pins the book for the current user' do
      send_request

      expect(response).to be_successful
      expect(json_response).to eq(book_id: book.id, pinned: true)
      expect(UserPin.exists?(user: reader, entity: book)).to be(true)
    end

    it 'does not create a second row when the book is already pinned' do
      create(:user_pin, user: reader, entity: book)

      send_request

      expect(response).to be_successful
      expect(UserPin.where(user: reader, entity: book).count).to eq(1)
    end

    it 'returns not found for an unknown book' do
      put '/api/books/pins/0.json'

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /:id' do
    subject(:send_request) { delete "/api/books/pins/#{book.id}.json" }

    it 'unpins the book for the current user and leaves other pins intact' do
      other_reader = create(:user)
      other_book = create(:book)
      create(:user_pin, user: reader, entity: book)
      create(:user_pin, user: other_reader, entity: book)
      create(:user_pin, user: reader, entity: other_book)

      send_request

      expect(response).to be_successful
      expect(json_response).to eq(book_id: book.id, pinned: false)
      expect(UserPin.exists?(user: reader, entity: book)).to be(false)
      expect(UserPin.exists?(user: other_reader, entity: book)).to be(true)
      expect(UserPin.exists?(user: reader, entity: other_book)).to be(true)
    end

    it 'succeeds when the book was not pinned' do
      send_request

      expect(response).to be_successful
      expect(json_response).to eq(book_id: book.id, pinned: false)
    end
  end
end
