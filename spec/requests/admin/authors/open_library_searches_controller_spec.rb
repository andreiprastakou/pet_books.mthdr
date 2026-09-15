require 'rails_helper'

RSpec.describe Admin::Authors::OpenLibrarySearchesController do
  describe 'POST /admin/authors/:author_id/open_library_searches' do
    let(:send_request) { post admin_author_open_library_searches_path(author), headers: authorization_header }
    let(:author) { create(:author) }

    it 'creates a search task, enqueues it, and redirects with a notice' do
      expect { send_request }.to change(Admin::Tasks::OpenLibraryAuthorSearch, :count).by(1)
        .and have_enqueued_job(Admin::DataFetchJob)
      expect(Admin::Tasks::OpenLibraryAuthorSearch.last.target).to eq(author)
      expect(response).to redirect_to(admin_author_path(author))
      expect(flash[:notice]).to eq('Open Library search has been queued.')
    end
  end
end
