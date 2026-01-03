require 'rails_helper'

RSpec.describe Admin::Authors::WikiStatsController do
  let(:author) { create(:author) }

  describe 'PUT /admin/authors/:id/wiki_stats' do
    let(:send_request) { put admin_author_wiki_stats_path(author), headers: authorization_header }

    let(:syncer) { instance_double(InfoFetchers::Wiki::BookSyncer) }
    let(:books) do
      [
        create(:book, authors: [author], wiki_popularity: 0),
        create(:book, authors: [author], wiki_popularity: 0, wiki_url: 'https://en.wikipedia.org/wiki/Book_2'),
        create(:book, authors: [author], wiki_popularity: 100)
      ]
    end

    before do
      allow(InfoFetchers::Wiki::BookSyncer).to receive(:new).and_return(syncer)
      allow(syncer).to receive(:sync!)
      books
    end

    it 'syncs the author\'s books that had no wiki stats' do
      send_request
      expect(InfoFetchers::Wiki::BookSyncer).to have_received(:new).with(books[1])
      expect(syncer).to have_received(:sync!)
    end

    it 'redirects to the author' do
      send_request
      expect(response).to redirect_to(admin_author_path(author))
      expect(flash[:notice]).to eq('Wiki stats were updated.')
    end

    context 'when there are no books to sync' do
      let(:books) { [create(:book, authors: [author], wiki_popularity: 0, wiki_url: nil)] }

      it 'redirects with a message' do
        send_request
        expect(response).to redirect_to(admin_author_path(author))
        expect(flash[:alert]).to eq('Nothing to sync.')
      end
    end
  end
end
