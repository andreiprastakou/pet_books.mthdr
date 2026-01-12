require 'rails_helper'

RSpec.describe '/api/books/years' do
  describe 'PUT /:id' do
    subject(:send_request) { get '/api/books/years.json', headers: authorization_header }

    let(:book) { create(:book, popularity: 4000) }

    before do
      create(:book, year_published: 1900)
      create(:book, year_published: 1901)
      create(:book, year_published: 1902)
    end

    it 'returns years of books publishing' do
      send_request

      expect(response).to be_successful
      expect(json_response).to eq([1900, 1901, 1902])
    end
  end
end
