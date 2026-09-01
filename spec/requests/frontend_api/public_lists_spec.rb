require 'rails_helper'

RSpec.describe '/api/public_lists' do
  describe 'GET /:id' do
    subject(:send_request) do
      get "/api/public_lists/#{public_list.id}.json", headers: authorization_header
    end

    let(:public_list) { create(:public_list, year: 2021) }
    let(:book) { create(:book) }

    before do
      public_list.book_public_lists.create!(book: book, role: 'winner')
    end

    it 'returns the list and book roles' do
      send_request

      expect(response).to be_successful
      expect(json_response).to eq(
        id: public_list.id,
        public_list_type_id: public_list.public_list_type_id,
        year: 2021,
        wiki_url: nil,
        generic_links: [],
        books: [{ id: book.id, role: 'winner' }]
      )
    end
  end
end
