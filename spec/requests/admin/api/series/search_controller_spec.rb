require 'rails_helper'

RSpec.describe Admin::Api::Series::SearchController do
  describe 'GET /admin/api/series/search.json' do
    let(:send_request) { get admin_api_series_search_path(format: :json), params: params, headers: authorization_header }
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
      let(:params) { { q: 'Fantasy' } }
      let!(:series1) { create(:series, name: 'Fantasy Series One') }
      let!(:series2) { create(:series, name: 'Fantasy Series Two') }
      let!(:series3) { create(:series, name: 'Science Fiction Series') }

      it 'returns matching series' do
        send_request
        expect(response).to be_successful
        expect(json_response).to contain_exactly(
          { id: series1.id, label: 'Fantasy Series One' },
          { id: series2.id, label: 'Fantasy Series Two' }
        )
      end

      it 'orders results by name' do
        send_request
        expect(response).to be_successful
        labels = json_response.map { |s| s[:label] }
        expect(labels).to eq(labels.sort)
      end
    end

    context 'when query has no matches' do
      let(:params) { { q: 'NonExistent' } }
      let!(:series) { create(:series, name: 'Fantasy Series') }

      it 'returns an empty array' do
        send_request
        expect(response).to be_successful
        expect(json_response).to eq([])
      end
    end

    context 'when there are more than 10 matches' do
      let(:params) { { q: 'Series' } }

      before do
        12.times { |i| create(:series, name: "Series #{i}") }
      end

      it 'limits results to 10' do
        send_request
        expect(response).to be_successful
        expect(json_response.length).to eq(10)
      end
    end

    context 'with partial matches' do
      let(:params) { { q: 'asy' } }
      let!(:series1) { create(:series, name: 'Fantasy Series') }
      let!(:series2) { create(:series, name: 'Mystery Series') }

      it 'returns partial matches' do
        send_request
        expect(response).to be_successful
        expect(json_response).to contain_exactly(
          { id: series1.id, label: 'Fantasy Series' }
        )
      end
    end
  end
end
