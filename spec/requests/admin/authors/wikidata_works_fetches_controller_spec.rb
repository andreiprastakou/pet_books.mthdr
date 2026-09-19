require 'rails_helper'

RSpec.describe Admin::Authors::WikidataWorksFetchesController do
  describe 'POST /admin/authors/:author_id/external_identities/:external_identity_id/wikidata_works_fetches' do
    let(:author) { create(:author) }
    let(:external_identity) do
      create(:external_identity, owner: author, external_resource: :wikidata, external_id: 'Q23434')
    end
    let(:send_request) do
      post admin_author_external_identity_wikidata_works_fetches_path(author, external_identity),
           headers: authorization_header
    end

    it 'creates a works fetch task, enqueues it, and redirects with a notice' do
      expect { send_request }.to change(Admin::Tasks::WikidataAuthorWorksFetch, :count).by(1)
        .and have_enqueued_job(Admin::DataFetchJob)
      task = Admin::Tasks::WikidataAuthorWorksFetch.last
      expect(task.target).to eq(author)
      expect(task.input_data).to eq('entity_id' => 'Q23434')
      expect(response).to redirect_to(admin_author_path(author))
      expect(flash[:notice]).to eq('Wikidata works fetch has been queued.')
    end
  end
end
