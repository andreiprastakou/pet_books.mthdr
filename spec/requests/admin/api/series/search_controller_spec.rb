require 'rails_helper'

RSpec.describe Admin::Api::Series::SearchController do
  describe 'GET /admin/api/series/search.json' do
    let(:send_request) do
      get admin_api_series_search_path(format: :json), params: params, headers: authorization_header
    end
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
      let(:series) do
        [
          create(:series, name: 'Fantasy Series One'),
          create(:series, name: 'Fantasy Series Two'),
          create(:series, name: 'Science Fiction Series')
        ]
      end

      it 'returns matching series' do
        series
        send_request
        expect(response).to be_successful
        expect(json_response).to contain_exactly(
          { id: series[0].id, label: 'Fantasy Series One' },
          { id: series[1].id, label: 'Fantasy Series Two' }
        )
      end

      it 'orders results by name' do
        send_request
        expect(response).to be_successful
        labels = json_response.pluck(:label)
        expect(labels).to eq(labels.sort)
      end
    end

    context 'when query has no matches' do
      let(:params) { { q: 'NonExistent' } }
      let(:series) { [create(:series, name: 'Fantasy Series')] }

      it 'returns an empty array' do
        series
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
      let(:series) do
        [
          create(:series, name: 'Fantasy Series'),
          create(:series, name: 'Mystery Series')
        ]
      end

      it 'returns partial matches' do
        series
        send_request
        expect(response).to be_successful
        expect(json_response).to contain_exactly(
          { id: series[0].id, label: 'Fantasy Series' }
        )
      end
    end
  end
end
