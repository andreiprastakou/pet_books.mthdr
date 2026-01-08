require 'rails_helper'

RSpec.describe '/api/authors/search' do
  let(:author) { build_stubbed(:author) }

  describe 'GET /' do
    subject(:send_request) { get '/api/authors/search.json', params: params, headers: authorization_header }

    let(:params) { { key: 'PERE' } }

    before { authors }

    let(:authors) do
      [
        create(:author, fullname: 'Alexandre Dumas'),
        create(:author, fullname: 'Alexandre Dumas fils'),
        create(:author, fullname: 'Alexandre Dumas pere')
      ]
    end

    it 'returns found matches' do
      send_request
      expect(response).to be_successful
      expect(json_response).to eq([
        { author_id: authors[2].id, label: 'Alexandre Dumas pere' }
      ])
    end
  end
end
