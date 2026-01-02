require 'rails_helper'

RSpec.describe Admin::BooksController do
  let(:author) { create(:author) }
  let(:valid_attributes) do
    {
      title: 'Test Book',
      author_ids: [author.id],
      year_published: 2023
    }
  end

  let(:invalid_attributes) do
    {
      title: '',
      author_ids: [author.id],
      year_published: 2023
    }
  end

  let(:book) { create(:book, authors: [author]) }

  describe 'GET /admin/books' do
    let(:send_request) { get admin_books_path, headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/books/index'
    end
  end

  describe 'GET /admin/books/:id' do
    let(:send_request) { get admin_book_path(book), headers: authorization_header }

    before { create(:cover_design, name: 'default') }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/books/show'
    end
  end

  describe 'GET /admin/books/new' do
    let(:send_request) { get new_admin_book_path, headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/books/new'
    end
  end

  describe 'GET /admin/books/:id/edit' do
    let(:send_request) { get edit_admin_book_path(book), headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/books/edit'
    end
  end

  describe 'POST /admin/books' do
    context 'with valid parameters' do
      let(:send_request) do
        post admin_books_path, params: { book: valid_attributes }, headers: authorization_header
      end

      it 'creates a new Book' do
        expect do
          send_request
        end.to change(Book, :count).by(1)
      end

      it 'redirects to the created book' do
        send_request
        expect(response).to redirect_to(admin_book_path(Book.last))
        expect(flash[:notice]).to eq('Book was successfully created.')
      end
    end

    context 'with invalid parameters' do
      let(:send_request) do
        post admin_books_path(format: :html), params: { book: invalid_attributes }, headers: authorization_header
      end

      it 'does not create a new Book' do
        expect do
          send_request
        end.not_to change(Book, :count)
      end

      it 'renders the form again' do
        send_request
        expect(response).to render_template 'admin/books/new'
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'PATCH /admin/books/:id' do
    let(:new_attributes) do
      {
        title: 'Updated Book Title'
      }
    end
    let(:send_request) do
      patch admin_book_path(book), params: { book: new_attributes }, headers: authorization_header
    end

    it 'updates the requested book' do
      send_request
      book.reload
      expect(book.title).to eq('Updated Book Title')
    end

    it 'redirects to the book' do
      send_request
      expect(response).to redirect_to(admin_book_path(book))
      expect(flash[:notice]).to eq('Book was successfully updated.')
    end

    context 'with invalid parameters' do
      let(:send_request) do
        patch admin_book_path(book), params: { book: invalid_attributes }, headers: authorization_header
      end

      it 'renders the form again' do
        send_request
        expect(response).to render_template 'admin/books/edit'
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'DELETE /admin/books/:id' do
    let(:send_request) { delete admin_book_path(book), headers: authorization_header }

    it 'destroys the requested book' do
      book
      expect do
        send_request
      end.to change(Book, :count).by(-1)
    end

    it 'redirects to the books list' do
      send_request
      expect(response).to redirect_to(admin_books_path)
      expect(flash[:notice]).to eq('Book was successfully destroyed.')
    end
  end
end
