require 'rails_helper'

RSpec.describe Admin::Books::WikidataFetchesController do
  describe 'POST /admin/books/:book_id/external_identities/:external_identity_id/wikidata_fetches' do
    let(:book) { create(:book) }
    let(:external_identity) do
      create(:external_identity, owner: book, external_resource: :wikidata, external_id: 'Q74287')
    end
    let(:send_request) do
      post admin_book_external_identity_wikidata_fetches_path(book, external_identity),
           headers: authorization_header
    end

    it 'creates a fetch task, enqueues it, and redirects with a notice' do
      expect { send_request }.to change(Admin::Tasks::WikidataBookFetch, :count).by(1)
                                                                                .and have_enqueued_job(Admin::DataFetchJob)
      expect(Admin::Tasks::WikidataBookFetch.last.target).to eq(external_identity)
      expect(response).to redirect_to(admin_book_path(book))
      expect(flash[:notice]).to eq('Wikidata data fetch has been queued.')
    end
  end
end
