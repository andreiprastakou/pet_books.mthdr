# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/authors/pins' do
  let(:reader) { create(:user) }
  let(:author) { create(:author) }

  before { sign_in_frontend_user!(reader) }

  describe 'PUT /:id' do
    subject(:send_request) { put "/api/authors/pins/#{author.id}.json" }

    it 'pins the author for the current user' do
      send_request

      expect(response).to be_successful
      expect(json_response).to eq(author_id: author.id, pinned: true)
      expect(UserPin.exists?(user: reader, entity: author)).to be(true)
    end

    it 'does not create a second row when the author is already pinned' do
      create(:user_pin, user: reader, entity: author)

      send_request

      expect(response).to be_successful
      expect(UserPin.where(user: reader, entity: author).count).to eq(1)
    end

    it 'returns not found for an unknown author' do
      put '/api/authors/pins/0.json'

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /:id' do
    subject(:send_request) { delete "/api/authors/pins/#{author.id}.json" }

    it 'unpins the author for the current user and leaves other pins intact' do
      other_reader = create(:user)
      other_author = create(:author)
      create(:user_pin, user: reader, entity: author)
      create(:user_pin, user: other_reader, entity: author)
      create(:user_pin, user: reader, entity: other_author)

      send_request

      expect(response).to be_successful
      expect(json_response).to eq(author_id: author.id, pinned: false)
      expect(UserPin.exists?(user: reader, entity: author)).to be(false)
      expect(UserPin.exists?(user: other_reader, entity: author)).to be(true)
      expect(UserPin.exists?(user: reader, entity: other_author)).to be(true)
    end

    it 'succeeds when the author was not pinned' do
      send_request

      expect(response).to be_successful
      expect(json_response).to eq(author_id: author.id, pinned: false)
    end
  end
end
