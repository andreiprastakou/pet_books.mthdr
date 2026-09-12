require 'rails_helper'

RSpec.describe Admin::Books::OpenLibrarySearchesController do
  describe 'POST /admin/books/:book_id/open_library_searches' do
    let(:send_request) { post admin_book_open_library_searches_path(book), headers: authorization_header }
    let(:book) { create(:book) }

    it 'creates a search task, enqueues it, and redirects with a notice' do
      expect { send_request }.to change(Admin::OpenLibrarySearchTask, :count).by(1)
        .and have_enqueued_job(Admin::DataFetchJob)
      expect(Admin::OpenLibrarySearchTask.last.target).to eq(book)
      expect(response).to redirect_to(admin_book_path(book))
      expect(flash[:notice]).to eq('Open Library search has been queued.')
    end
  end
end
