require 'rails_helper'

RSpec.describe '/api/tags/categories' do
  describe 'GET /' do
    subject(:send_request) { get '/api/tags/categories.json', headers: authorization_header }

    it 'returns a list of all categories' do
      send_request

      expect(response).to be_successful
      expect(json_response).to contain_exactly(
        { id: 0, name: 'other' }, { id: 1, name: 'format' },
        { id: 2, name: 'genre' }, { id: 3, name: 'location' },
        { id: 4, name: 'series' }, { id: 5, name: 'award' },
        { id: 6, name: 'theme' }
      )
    end
  end
end
