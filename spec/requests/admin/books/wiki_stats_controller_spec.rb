require 'rails_helper'

RSpec.describe Admin::Books::WikiStatsController do
  let(:book) { create(:book, wiki_popularity: 100) }

  describe 'PUT /admin/books/:id/wiki_stats' do
    let(:send_request) { put admin_book_wiki_stats_path(book), headers: authorization_header }

    let(:syncer) { instance_double(Admin::InfoFetchers::Wiki::BookSyncer) }

    before do
      allow(Admin::InfoFetchers::Wiki::BookSyncer).to receive(:new) do |book_arg|
        allow(syncer).to receive(:sync!) do
          book_arg.update!(wiki_popularity: 101)
        end
        syncer
      end
    end

    it 'syncs the book' do
      send_request
      expect(book.reload.wiki_popularity).to eq(101)
      expect(syncer).to have_received(:sync!)
    end

    it 'redirects to the book' do
      send_request
      expect(response).to redirect_to(admin_book_path(book))
      expect(flash[:notice]).to eq('Wiki stats were updated.')
    end

    context 'when the stats dont change' do
      before do
        allow(Admin::InfoFetchers::Wiki::BookSyncer).to receive(:new).and_return(syncer)
        allow(syncer).to receive(:sync!)
      end

      it 'redirects with a message' do
        send_request
        expect(response).to redirect_to(admin_book_path(book))
        expect(flash[:alert]).to eq('No new stats.')
      end
    end
  end
end
