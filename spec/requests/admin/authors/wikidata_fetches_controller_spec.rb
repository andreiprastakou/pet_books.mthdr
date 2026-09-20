require 'rails_helper'

RSpec.describe Admin::Authors::WikidataFetchesController do
  describe 'POST /admin/authors/:author_id/external_identities/:external_identity_id/wikidata_fetches' do
    let(:author) { create(:author) }
    let(:external_identity) do
      create(:external_identity, owner: author, external_resource: :wikidata, external_id: 'Q892')
    end
    let(:send_request) do
      post admin_author_external_identity_wikidata_fetches_path(author, external_identity),
           headers: authorization_header
    end

    it 'creates a fetch task, enqueues it, and redirects with a notice' do
      expect { send_request }.to change(Admin::Tasks::WikidataAuthorFetch, :count).by(1)
                                                                                  .and have_enqueued_job(Admin::DataFetchJob)
      expect(Admin::Tasks::WikidataAuthorFetch.last.target).to eq(external_identity)
      expect(response).to redirect_to(admin_author_path(author))
      expect(flash[:notice]).to eq('Wikidata data fetch has been queued.')
    end
  end
end
