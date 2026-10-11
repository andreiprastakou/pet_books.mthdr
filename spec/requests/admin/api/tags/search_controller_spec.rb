require 'rails_helper'

RSpec.describe Admin::Api::Tags::SearchController do
  describe 'GET /admin/api/tags/search.json' do
    let(:send_request) do
      get admin_api_tags_search_path(format: :json), params: params, headers: authorization_header
    end
    let(:params) { { q: 'spa' } }

    context 'with matching tags' do
      let!(:tags) do
        [
          create(:tag, name: 'space_opera'),
          create(:tag, name: 'spanish_literature'),
          create(:tag, name: 'fantasy')
        ]
      end

      it 'returns matching tags' do
        send_request
        expect(response).to be_successful
        expect(response.parsed_body).to eq(
          [
            { 'id' => tags[0].id, 'label' => 'space_opera' },
            { 'id' => tags[1].id, 'label' => 'spanish_literature' }
          ]
        )
      end
    end

    context 'with a blank query' do
      let(:params) { { q: '' } }

      it 'returns an empty list' do
        create(:tag, name: 'space_opera')
        send_request
        expect(response.parsed_body).to eq([])
      end
    end
  end
end
