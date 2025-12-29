require 'rails_helper'

RSpec.describe Admin::Authors::BooksController do
  let(:author) { create(:author) }

  describe 'GET /admin/authors/:id/books/new' do
    let(:send_request) { get new_admin_author_book_path(author), headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/authors/books/new'
      expect(assigns(:book)).to be_a(Admin::BookForm)
    end
  end
end
