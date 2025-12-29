require 'rails_helper'

RSpec.describe Admin::Api::Books::SearchController do
  describe 'GET /admin/api/books/search.json' do
    let(:send_request) do
      get admin_api_books_search_path(format: :json), params: params, headers: authorization_header
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
      let(:books) do
        [
          create(:book, title: 'Fantasy Book One'),
          create(:book, title: 'Fantasy Book Two'),
          create(:book, title: 'Science Fiction Book')
        ]
      end

      it 'returns matching books' do
        books
        send_request
        expect(response).to be_successful
        expect(json_response).to contain_exactly(
          { id: books[0].id, label: match(/Fantasy Book One/i) },
          { id: books[1].id, label: match(/Fantasy Book Two/i) }
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
      let(:books) { [create(:book, title: 'Fantasy Book')] }

      it 'returns an empty array' do
        books
        send_request
        expect(response).to be_successful
        expect(json_response).to eq([])
      end
    end

    context 'when there are more than 10 matches' do
      let(:params) { { q: 'Book' } }

      before do
        12.times { |i| create(:book, title: "Book #{i}") }
      end

      it 'limits results to 10' do
        send_request
        expect(response).to be_successful
        expect(json_response.length).to eq(10)
      end
    end

    context 'with partial matches' do
      let(:params) { { q: 'asy' } }
      let(:books) do
        [
          create(:book, title: 'Fantasy Book'),
          create(:book, title: 'Mystery Book')
        ]
      end

      it 'returns partial matches' do
        books
        send_request
        expect(response).to be_successful
        expect(json_response).to contain_exactly(
          { id: books[0].id, label: match(/Fantasy Book/i) }
        )
      end
    end
  end
end
