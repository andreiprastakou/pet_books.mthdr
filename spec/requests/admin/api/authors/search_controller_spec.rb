require 'rails_helper'

RSpec.describe Admin::Api::Authors::SearchController do
  describe 'GET /admin/api/authors/search.json' do
    let(:send_request) { get admin_api_authors_search_path(format: :json), params: params, headers: authorization_header }
    let(:params) { {} }

    context 'when query is empty' do
      it 'returns an empty array' do
        send_request
        expect(response).to be_successful
        expect(json_response).to eq([])
      end
    end

    context 'when query is blank' do
      let(:params) { { q: '   ' } }

      it 'returns an empty array' do
        send_request
        expect(response).to be_successful
        expect(json_response).to eq([])
      end
    end

    context 'when query has matches' do
      let(:params) { { q: 'King' } }
      let!(:author1) { create(:author, fullname: 'King Henry I') }
      let!(:author2) { create(:author, fullname: 'King Henry II') }
      let!(:author3) { create(:author, fullname: 'Queen Elizabeth') }

      it 'returns matching authors' do
        send_request
        expect(response).to be_successful
        expect(json_response).to contain_exactly(
          { id: author1.id, label: 'King Henry I' },
          { id: author2.id, label: 'King Henry II' }
        )
      end

      it 'orders results by fullname' do
        send_request
        expect(response).to be_successful
        labels = json_response.map { |a| a[:label] }
        expect(labels).to eq(labels.sort)
      end
    end

    context 'when query has no matches' do
      let(:params) { { q: 'NonExistent' } }
      let!(:author) { create(:author, fullname: 'King Henry I') }

      it 'returns an empty array' do
        send_request
        expect(response).to be_successful
        expect(json_response).to eq([])
      end
    end

    context 'when there are more than 10 matches' do
      let(:params) { { q: 'King' } }

      before do
        12.times { |i| create(:author, fullname: "King Henry #{i}") }
      end

      it 'limits results to 10' do
        send_request
        expect(response).to be_successful
        expect(json_response.length).to eq(10)
      end
    end

    context 'with partial matches' do
      let(:params) { { q: 'enry' } }
      let!(:author1) { create(:author, fullname: 'King Henry I') }
      let!(:author2) { create(:author, fullname: 'Queen Elizabeth') }

      it 'returns partial matches' do
        send_request
        expect(response).to be_successful
        expect(json_response).to contain_exactly(
          { id: author1.id, label: 'King Henry I' }
        )
      end
    end
  end
end
