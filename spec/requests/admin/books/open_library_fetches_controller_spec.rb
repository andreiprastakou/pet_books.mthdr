require 'rails_helper'

RSpec.describe Admin::Books::OpenLibraryFetchesController do
  describe 'POST /admin/books/:book_id/external_identities/:external_identity_id/open_library_fetches' do
    let(:book) { create(:book) }
    let!(:external_identity) do
      create(:external_identity, owner: book, external_resource: :open_library, external_id: 'OL99W')
    end
    let(:send_request) do
      post admin_book_external_identity_open_library_fetches_path(book, external_identity),
           headers: authorization_header
    end

    it 'creates a fetch task, enqueues it, and redirects with a notice' do
      expect { send_request }.to change(Admin::Tasks::OpenLibraryBookFetch, :count).by(1)
        .and have_enqueued_job(Admin::DataFetchJob)
      expect(Admin::Tasks::OpenLibraryBookFetch.last.target).to eq(external_identity)
      expect(response).to redirect_to(admin_book_path(book))
      expect(flash[:notice]).to eq('Open Library data fetch has been queued.')
    end
  end
end
