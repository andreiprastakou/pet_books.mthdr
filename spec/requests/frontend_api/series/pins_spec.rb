# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/series/pins' do
  let(:reader) { create(:user) }
  let(:series) { create(:series) }

  before { sign_in_frontend_user!(reader) }

  describe 'PUT /:id' do
    subject(:send_request) { put "/api/series/pins/#{series.id}.json" }

    it 'pins the series for the current user' do
      send_request

      expect(response).to be_successful
      expect(json_response).to eq(series_id: series.id, pinned: true)
      expect(UserPin.exists?(user: reader, entity: series)).to be(true)
    end

    it 'does not create a second row when the series is already pinned' do
      create(:user_pin, user: reader, entity: series)

      send_request

      expect(response).to be_successful
      expect(UserPin.where(user: reader, entity: series).count).to eq(1)
    end

    it 'returns not found for an unknown series' do
      put '/api/series/pins/0.json'

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /:id' do
    subject(:send_request) { delete "/api/series/pins/#{series.id}.json" }

    it 'unpins the series for the current user and leaves other pins intact' do
      other_reader = create(:user)
      other_series = create(:series)
      create(:user_pin, user: reader, entity: series)
      create(:user_pin, user: other_reader, entity: series)
      create(:user_pin, user: reader, entity: other_series)

      send_request

      expect(response).to be_successful
      expect(json_response).to eq(series_id: series.id, pinned: false)
      expect(UserPin.exists?(user: reader, entity: series)).to be(false)
      expect(UserPin.exists?(user: other_reader, entity: series)).to be(true)
      expect(UserPin.exists?(user: reader, entity: other_series)).to be(true)
    end

    it 'succeeds when the series was not pinned' do
      send_request

      expect(response).to be_successful
      expect(json_response).to eq(series_id: series.id, pinned: false)
    end
  end
end
