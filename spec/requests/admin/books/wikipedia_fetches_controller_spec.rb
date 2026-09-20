# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Books::WikipediaFetchesController do
  describe 'POST /admin/books/:book_id/wikipedia_fetches' do
    let(:book) { create(:book, wiki_url: 'https://en.wikipedia.org/wiki/The_Hobbit') }
    let(:send_request) do
      post admin_book_wikipedia_fetches_path(book), headers: authorization_header
    end

    it 'creates a fetch task, enqueues it, and redirects with a notice' do
      expect { send_request }.to change(Admin::Tasks::WikipediaBookFetch, :count).by(1)
                                                                                 .and have_enqueued_job(Admin::DataFetchJob)
      expect(Admin::Tasks::WikipediaBookFetch.last.target).to eq(book)
      expect(response).to redirect_to(admin_book_path(book))
      expect(flash[:notice]).to eq('Wikipedia intro fetch has been queued.')
    end
  end
end
