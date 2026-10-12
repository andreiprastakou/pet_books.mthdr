# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/user_reads_sharings' do
  let(:reader) { create(:user) }

  before { sign_in_frontend_user!(reader) }

  describe 'POST /' do
    subject(:send_request) { post '/api/user_reads_sharings.json', headers: authorization_header }

    it 'creates a sharing code for the current user' do
      send_request

      expect(response).to be_successful
      expect(json_response[:code]).to match(/\A[0-9a-f]{16}\z/)
      expect(UserReadsSharing.find_by!(user: reader).code).to eq(json_response[:code])
    end

    it 'returns the existing code instead of creating another' do
      sharing = create(:user_reads_sharing, user: reader, code: 'a' * 16)

      send_request

      expect(response).to be_successful
      expect(json_response).to eq(code: sharing.code)
      expect(UserReadsSharing.where(user: reader).count).to eq(1)
    end
  end

  describe 'GET /:code' do
    it 'returns the sharing code' do
      sharing = create(:user_reads_sharing, code: 'b' * 16)

      get "/api/user_reads_sharings/#{sharing.code}.json", headers: authorization_header

      expect(response).to be_successful
      expect(json_response).to eq(code: sharing.code)
    end

    it 'returns not found for an unknown code' do
      get '/api/user_reads_sharings/missingcode00000.json', headers: authorization_header

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /current' do
    it 'returns the current user sharing code' do
      sharing = create(:user_reads_sharing, user: reader, code: 'c' * 16)

      get '/api/user_reads_sharings/current.json', headers: authorization_header

      expect(response).to be_successful
      expect(json_response).to eq(code: sharing.code)
    end

    it 'returns not found when the current user has not shared' do
      get '/api/user_reads_sharings/current.json', headers: authorization_header

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /current' do
    it 'deletes the current user sharing code' do
      create(:user_reads_sharing, user: reader, code: 'd' * 16)
      create(:user_reads_sharing, code: 'e' * 16)

      delete '/api/user_reads_sharings/current.json', headers: authorization_header

      expect(response).to have_http_status(:no_content)
      expect(UserReadsSharing.where(user: reader)).to be_empty
      expect(UserReadsSharing.find_by(code: 'e' * 16)).to be_present
    end

    it 'succeeds when the current user has not shared' do
      delete '/api/user_reads_sharings/current.json', headers: authorization_header

      expect(response).to have_http_status(:no_content)
    end
  end
end
