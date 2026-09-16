# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Authors::WikipediaFetchesController do
  describe 'POST /admin/authors/:author_id/wikipedia_fetches' do
    let(:author) { create(:author, wiki_url: 'https://en.wikipedia.org/wiki/J._R._R._Tolkien') }
    let(:send_request) do
      post admin_author_wikipedia_fetches_path(author), headers: authorization_header
    end

    it 'creates a fetch task, enqueues it, and redirects with a notice' do
      expect { send_request }.to change(Admin::Tasks::WikipediaAuthorFetch, :count).by(1)
        .and have_enqueued_job(Admin::DataFetchJob)
      expect(Admin::Tasks::WikipediaAuthorFetch.last.target).to eq(author)
      expect(response).to redirect_to(admin_author_path(author))
      expect(flash[:notice]).to eq('Wikipedia intro fetch has been queued.')
    end
  end
end
