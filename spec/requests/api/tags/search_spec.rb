require 'rails_helper'

RSpec.describe '/api/tags/search' do
  let(:tag) { build_stubbed(:tag) }

  describe 'GET /' do
    subject(:send_request) { get '/api/tags/search.json', params: params, headers: authorization_header }

    let(:params) { { key: 'IPSUM' } }

    before { tags }

    let(:tags) do
      [
        create(:tag, name: 'lorem_ipsum_dolor'),
        create(:tag, name: 'ipsun')
      ]
    end

    it 'returns found matches' do
      send_request
      expect(response).to be_successful
      expect(json_response).to eq([
        { tag_id: tags[0].id, label: 'lorem_ipsum_dolor' }
      ])
    end
  end
end
