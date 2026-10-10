require 'rails_helper'

RSpec.describe Admin::Books::BatchRowsController do
  describe 'GET /admin/books/batch_rows/:id' do
    let(:author) { create(:author, fullname: 'Row Author') }
    let(:series) { create(:series, name: 'Row Series') }
    let(:book) do
      create(:book,
             title: 'Persisted Story',
             original_title: 'Histoire',
             literary_form: 'short',
             year_published: 1977,
             authors: [author],
             series: [series])
    end
    let(:send_request) do
      get admin_books_batch_row_path(book), params: { index: '171000' }, headers: authorization_header
    end

    before do
      create(:external_link, owner: book, external_resource: ExternalResources::WIKIPEDIA,
                             url: 'https://en.wikipedia.org/wiki/Persisted_Story')
    end

    it 'renders the persisted book as a batch row' do
      send_request

      expect(response).to be_successful
      expect(response.body).to include('name="batch[171000][id]"')
      expect(response.body).to include("value=\"#{book.id}\"")
      expect(response.body).to include('Persisted Story')
      expect(response.body).to include('Histoire')
      expect(response.body).to include('value="short"')
      expect(response.body).to include('value="1977"')
      expect(response.body).to include('Row Author')
      expect(response.body).to include('Row Series')
      expect(response.body).to include('https://en.wikipedia.org/wiki/Persisted_Story')
      expect(response.body).to include('data-books-batch-form-target="bookEntry"')
    end

    it 'ignores a non-numeric index' do
      get admin_books_batch_row_path(book), params: { index: '1][title]' }, headers: authorization_header

      expect(response).to be_successful
      expect(response.body).not_to include('batch[1][title][title]')
    end
  end
end
