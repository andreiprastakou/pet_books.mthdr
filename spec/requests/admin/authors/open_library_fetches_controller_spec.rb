require 'rails_helper'

RSpec.describe Admin::Authors::OpenLibraryFetchesController do
  describe 'POST /admin/authors/:author_id/external_identities/:external_identity_id/open_library_fetches' do
    let(:author) { create(:author) }
    let!(:external_identity) do
      create(:external_identity, owner: author, external_resource: :open_library, external_id: 'OL99A')
    end
    let(:send_request) do
      post admin_author_external_identity_open_library_fetches_path(author, external_identity),
           headers: authorization_header
    end

    it 'creates a fetch task, enqueues it, and redirects with a notice' do
      expect { send_request }.to change(Admin::Tasks::OpenLibraryAuthorFetch, :count).by(1)
                                                                                     .and have_enqueued_job(Admin::DataFetchJob)
      expect(Admin::Tasks::OpenLibraryAuthorFetch.last.target).to eq(external_identity)
      expect(response).to redirect_to(admin_author_path(author))
      expect(flash[:notice]).to eq('Open Library data fetch has been queued.')
    end
  end
end
