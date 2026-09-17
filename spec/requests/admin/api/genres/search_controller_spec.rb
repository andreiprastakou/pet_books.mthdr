require 'rails_helper'

RSpec.describe Admin::Api::Genres::SearchController do
  describe 'GET /admin/api/genres/search.json' do
    let(:send_request) do
      get admin_api_genres_search_path(format: :json), params: params, headers: authorization_header
    end
    let(:params) { { q: 'sci' } }

    context 'with matching genres' do
      let!(:genres) do
        [
          create(:genre, name: 'science_fiction'),
          create(:genre, name: 'scientific_romance'),
          create(:genre, name: 'fantasy')
        ]
      end

      it 'returns matching genres' do
        send_request
        expect(response).to be_successful
        expect(response.parsed_body).to eq(
          [
            { 'id' => genres[0].id, 'label' => 'science_fiction' },
            { 'id' => genres[1].id, 'label' => 'scientific_romance' }
          ]
        )
      end
    end

    context 'with a blank query' do
      let(:params) { { q: '' } }

      it 'returns an empty list' do
        create(:genre, name: 'science_fiction')
        send_request
        expect(response.parsed_body).to eq([])
      end
    end
  end
end
