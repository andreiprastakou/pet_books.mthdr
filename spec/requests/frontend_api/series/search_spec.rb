require 'rails_helper'

RSpec.describe '/api/series/search' do
  describe 'GET /' do
    subject(:send_request) { get '/api/series/search.json', params: params, headers: authorization_header }

    let(:params) { { key: 'Earth' } }
    let(:series_list) do
      [
        create(:series, name: 'Earthsea'),
        create(:series, name: 'Dune')
      ]
    end

    before { series_list }

    it 'returns found matches' do
      send_request
      expect(response).to be_successful
      expect(json_response).to eq([
                                    { series_id: series_list[0].id, label: 'Earthsea' }
                                  ])
    end
  end
end
