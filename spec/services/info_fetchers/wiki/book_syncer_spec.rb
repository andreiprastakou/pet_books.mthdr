require 'rails_helper'

RSpec.describe InfoFetchers::Wiki::BookSyncer do
  describe '#sync!' do
    subject(:call) { described_class.new(book).sync! }

    let(:book) { create(:book, wiki_url: 'https://en.wikipedia.org/wiki/Crime_and_Punishment') }

    let(:variants_fetcher) { instance_double(InfoFetchers::Wiki::VariantsFetcher) }
    let(:views_fetcher) { instance_double(InfoFetchers::Wiki::ViewsFetcher) }

    around do |example|
      Timecop.freeze(Time.current.change(usec: 0)) do
        example.run
      end
    end

    before do
      allow(InfoFetchers::Wiki::UrlParser).to receive(:extract_base_name_and_locale)
        .with(book.wiki_url).and_return(['Crime and Punishment', 'en'])
      allow(InfoFetchers::Wiki::VariantsFetcher).to receive(:new).and_return(variants_fetcher)
      allow(variants_fetcher).to receive(:fetch_variants).with('Crime and Punishment', 'en')
                                                         .and_return({ 'en' => 'Crime and Punishment',
                                                                       'ru' => 'Преступление и наказание' })
      allow(InfoFetchers::Wiki::ViewsFetcher).to receive(:new).and_return(views_fetcher)
      allow(views_fetcher).to receive(:fetch).with('Crime and Punishment', 'en', last_synced_at: nil)
                                             .and_return([101, 11])
    end

    it 'syncs the book' do
      expect { call }.to change(book, :wiki_popularity).to(101)
    end

    context 'when the book has no wiki_url' do
      before { book.wiki_url = nil }

      it 'raises an error' do
        expect { call }.to raise_error(RuntimeError, "No wiki_url for book #{book.id}")
      end
    end

    context 'when the book had no wiki_links' do
      it 'creates wiki_links' do
        expect { call }.to change(book.wiki_links, :count).by(1)
        expect(
          book.wiki_links.pluck(:locale, :name, :views, :views_last_month, :views_synced_at)
        ).to contain_exactly(['en', 'Crime and Punishment', 101, 11, Time.current])
      end

      context 'when wiki_url is unparseable' do
        before do
          allow(InfoFetchers::Wiki::UrlParser).to receive(:extract_base_name_and_locale).with(book.wiki_url)
                                                                                        .and_return(nil)
        end

        it 'raises an error' do
          expect { call }.to raise_error(RuntimeError, "Can't extract base name and locale from #{book.wiki_url}")
        end
      end
    end

    context 'when the book had wiki_links' do
      before do
        old_link
        allow(views_fetcher).to receive(:fetch).with('Crime and Punishment', 'en', last_synced_at: 3.months.ago)
                                               .and_return([301, 31])
        book.wiki_popularity = 101
      end

      let(:old_link) do
        create(:wiki_link, entity: book, locale: 'en', name: 'Crime and Punishment', views: 101,
                           url: 'https://en.wikipedia.org/wiki/Crime_and_Punishment',
                           views_last_month: 11, views_synced_at: 3.months.ago)
      end

      it 'only updates the old stats', :aggregate_failures do
        expect { call }.not_to change(WikiLink, :count)
        old_link.reload
        expect(book.reload.wiki_popularity).to eq(101 - 11 + 301)
        expect(old_link.views).to eq(101 - 11 + 301)
        expect(old_link.views_last_month).to eq(31)
        expect(old_link.views_synced_at).to eq(Time.current)
      end

      context 'when views could not be fetched' do
        before do
          allow(views_fetcher).to receive(:fetch).and_return(nil)
        end

        it 'does not update the book' do
          expect { call }.not_to change(book, :wiki_popularity)
        end
      end
    end
  end
end
