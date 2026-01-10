require 'rails_helper'

RSpec.describe '/api/books/search' do
  let(:book) { build_stubbed(:book) }

  describe 'GET /' do
    subject(:send_request) { get '/api/books/search.json', params: params, headers: authorization_header }

    let(:params) { { key: 'THE THREE' } }
    let(:books) do
      [
        create(:book, title: 'The Three Musketeers'),
        create(:book, title: 'Three Musketeers'),
        create(:book, title: 'Three Musketeers II')
      ]
    end

    before { books }

    it 'returns found matches' do
      send_request
      expect(response).to be_successful
      expect(json_response).to eq([
                                    {
                                      book_id: books[0].id,
                                      title: 'The Three Musketeers',
                                      year: books[0].year_published,
                                      author_id: books[0].author_ids.first
                                    }
                                  ])
    end
  end
end
