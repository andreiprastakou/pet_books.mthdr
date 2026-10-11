require 'rails_helper'

RSpec.describe Admin::Books::BatchRowsController do
  describe 'GET /admin/books/batch_rows/:id' do
    let(:author) { create(:author, fullname: 'Row Author') }
    let(:series) { create(:series, name: 'Row Series') }
    let(:book) do
      create(:book,
             title: 'Persisted Story',
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
      expect(response.body).not_to include('name="batch[171000][original_title]"')
      expect(response.body).to include('selected="selected" value="short"')
      expect(response.body).not_to include('will be replaced!')
      expect(response.body).to include('value="1977"')
      expect(response.body).to include('Row Author')
      expect(response.body).to include('Row Series')
      expect(response.body).to include('https://en.wikipedia.org/wiki/Persisted_Story')
      expect(response.body).to include("href=\"#{admin_book_path(book)}\"")
      expect(response.body).to include('target="_blank"')
      expect(response.body).to include(">#{book.id}</a>")
      expect(response.body).not_to include('disabled="disabled"')
    end

    it 'includes an ensured series the book does not have yet' do
      extra = create(:series, name: 'Ensured Series')

      get admin_books_batch_row_path(book),
          params: { index: '171000', ensure_series_id: extra.id },
          headers: authorization_header

      expect(response).to be_successful
      expect(response.body).to include('Row Series')
      expect(response.body.scan('Ensured Series').size).to eq(1)
      expect(Joins::BookSeries.where(book: book, series: extra)).not_to exist
    end

    it 'includes an ensured author the book does not have yet' do
      extra = create(:author, fullname: 'Ensured Author')

      get admin_books_batch_row_path(book),
          params: { index: '171000', ensure_author_id: extra.id },
          headers: authorization_header

      expect(response).to be_successful
      expect(response.body).to include('Row Author')
      expect(response.body.scan('Ensured Author').size).to eq(1)
      expect(Joins::BookAuthor.where(book: book, author: extra)).not_to exist
    end

    it 'adds an empty list role field when the membership column is requested' do
      get admin_books_batch_row_path(book),
          params: { index: '171000', membership_column: 'public_list_role' },
          headers: authorization_header

      expect(response).to be_successful
      expect(response.body).to include('name="batch[171000][membership][role]"')
      expect(response.body).to include('data-name="membership-role"')
      expect(response.body).to include('b-books-batch-membership')
    end

    it 'ignores an unknown membership column' do
      get admin_books_batch_row_path(book),
          params: { index: '171000', membership_column: 'other' },
          headers: authorization_header

      expect(response).to be_successful
      expect(response.body).not_to include('membership')
    end

    it 'ignores a non-numeric index' do
      get admin_books_batch_row_path(book), params: { index: '1][title]' }, headers: authorization_header

      expect(response).to be_successful
      expect(response.body).not_to include('batch[1][title][title]')
    end
  end
end
