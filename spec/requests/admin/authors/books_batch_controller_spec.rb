require 'rails_helper'

RSpec.describe Admin::Authors::BooksBatchController do
  let(:author) { create(:author, fullname: 'Title Author') }
  let(:other_author) { create(:author, fullname: 'Other Author') }

  describe 'GET /admin/authors/:author_id/books_batch/edit' do
    let(:send_request) { get edit_admin_author_books_batch_path(author), headers: authorization_header }

    before do
      create(:external_link, owner: author, url: 'https://example.com/title-author')
      create(:book, authors: [author, other_author], title: 'Shared Book')
    end

    it 'renders the author books batch edit page' do
      send_request

      expect(response).to be_successful
      expect(response).to render_template 'admin/authors/books_batch/edit'
      expect(response.body).to include('Books Batch Edit')
      expect(response.body).to include('title="Skip"')

      authors_panel = response.body.split('Books to update:').first
      expect(authors_panel).to include('Title Author')
      expect(authors_panel).to include('https://example.com/title-author')
      expect(authors_panel).not_to include('Other Author')
    end

    it 'prefills new rows with the title author' do
      send_request

      template = response.body[/<template[^>]*bookTemplate[\s\S]*?<\/template>/]
      expect(template).to include(author.id.to_s)
      expect(template).to include('Title Author')
      expect(template).not_to include('Other Author')
      expect(response.body).to include("ensure_author_id=#{author.id}")
    end
  end

  describe 'PUT /admin/authors/:author_id/books_batch' do
    let(:send_request) { put admin_author_books_batch_path(author), params: params, headers: authorization_header }
    let(:params) do
      {
        batch: {
          0 => {
            id: book.id,
            title: 'TITLE_UPDATED'
          }
        }
      }
    end
    let(:book) { build_stubbed(:book, authors: [author], title: 'TITLE') }
    let(:updater) { instance_double(Admin::BooksBatchUpdater) }

    before do
      allow(Admin::BooksBatchUpdater).to receive(:new).and_return(updater)
      allow(updater).to receive_messages(update: true, books: [book])
    end

    it 'updates and redirects to the author page' do
      send_request
      expect(updater).to have_received(:update)
      expect(response).to redirect_to admin_author_path(author)
    end

    context 'with invalid params' do
      before do
        allow(updater).to receive_messages(update: false, collect_errors: 'Title SOME_ERROR')
      end

      it 'renders the form again without updating books' do
        send_request
        expect(response).to render_template 'admin/authors/books_batch/edit'
        expect(response).to have_http_status(:unprocessable_content)
        expect(flash[:error]).to eq 'Failed to apply updates: Title SOME_ERROR.'
      end
    end
  end
end
