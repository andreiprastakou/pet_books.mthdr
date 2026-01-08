require 'rails_helper'

RSpec.describe InfoFetchers::Wiki::WikiLinksSyncer do
  around do |example|
    Timecop.freeze(Time.current.change(usec: 0)) do
      example.run
    end
  end

  describe '#sync!' do
    subject(:call) { syncer.sync! }

    let(:syncer) { described_class.new(wiki_link) }
    let(:wiki_link) { create(:wiki_link, entity: entity, views: 11, views_last_month: 7, views_synced_at: 1.day.ago) }
    let(:entity) { create(:author) }

    let(:views_fetcher) { instance_double(InfoFetchers::Wiki::ViewsFetcher) }

    before do
      allow(InfoFetchers::Wiki::ViewsFetcher).to receive(:new).and_return(views_fetcher)
      allow(views_fetcher).to receive(:fetch)
        .with(wiki_link.name, wiki_link.locale, last_synced_at: wiki_link.views_synced_at).and_return([13, 3])
    end

    it 'syncs the wiki link' do
      call
      expect(wiki_link.views).to eq(11 - 7 + 13)
      expect(wiki_link.views_last_month).to eq(3)
      expect(wiki_link.views_synced_at).to eq(Time.current)
    end

    context 'when the views could not be fetched' do
      before do
        allow(views_fetcher).to receive(:fetch).and_return(nil)
      end

      it 'does not update the wiki link' do
        call
        expect(wiki_link.views).to eq(11)
        expect(wiki_link.views_last_month).to eq(7)
      end
    end

    context 'when the entity is a book' do
      let(:entity) { create(:book, wiki_popularity: 5) }

      it 'updates the book' do
        call
        expect(entity.reload.wiki_popularity).to eq(11 - 7 + 13)
      end
    end
  end
end
