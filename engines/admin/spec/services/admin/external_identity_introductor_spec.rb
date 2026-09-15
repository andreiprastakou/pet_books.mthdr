# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ExternalIdentityIntroductor do
  describe '.call' do
    subject(:call) { described_class.call(identity) }

    context 'when a book open_library identity is created' do
      let(:book) { create(:book) }
      let(:identity) do
        create(:external_identity, owner: book, external_resource: :open_library, external_id: 'OL27448W')
      end

      it 'attaches an external link and enqueues an Open Library fetch task' do
        expect { call }.to change(book.external_links, :count).by(1)
                         .and change(Admin::Tasks::OpenLibraryBookFetch, :count).by(1)
                         .and have_enqueued_job(Admin::DataFetchJob)

        identity.reload
        expect(identity.external_link.url).to eq('https://openlibrary.org/works/OL27448W')
        expect(Admin::Tasks::OpenLibraryBookFetch.last.target).to eq(identity)
      end
    end

    context 'when an author open_library identity is created' do
      let(:author) { create(:author) }
      let(:identity) do
        create(:external_identity, owner: author, external_resource: :open_library, external_id: 'OL1394865A')
      end

      it 'attaches an author link and enqueues an Open Library author fetch task' do
        expect { call }.to change(author.external_links, :count).by(1)
                         .and change(Admin::Tasks::OpenLibraryAuthorFetch, :count).by(1)
                         .and have_enqueued_job(Admin::DataFetchJob)
                         .and change(Admin::Tasks::OpenLibraryBookFetch, :count).by(0)

        identity.reload
        expect(identity.external_link.url).to eq('https://openlibrary.org/authors/OL1394865A')
      end
    end

    context 'when a book wikidata identity is created' do
      let(:book) { create(:book) }
      let(:identity) do
        create(:external_identity, owner: book, external_resource: :wikidata, external_id: 'Q137179018')
      end

      it 'attaches a link but does not enqueue a fetch task' do
        expect { call }.to change(book.external_links, :count).by(1)
                         .and change(Admin::Tasks::OpenLibraryBookFetch, :count).by(0)
                         .and change(Admin::Tasks::WikidataBookFetch, :count).by(0)

        identity.reload
        expect(identity.external_link.url).to eq('https://www.wikidata.org/wiki/Q137179018')
      end
    end

    context 'when external_id does not change' do
      let(:book) { create(:book) }
      let!(:identity) do
        create(:external_identity, owner: book, external_resource: :open_library, external_id: 'OL1W')
      end

      before do
        identity.update!(external_resource: :wikidata)
      end

      it 'does nothing' do
        expect do
          described_class.call(identity)
        end.to change(book.external_links, :count).by(0)
           .and change(Admin::Tasks::OpenLibraryBookFetch, :count).by(0)

        expect(identity.reload.external_link).to be_nil
      end
    end

    context 'when external_id is updated' do
      let(:book) { create(:book) }
      let!(:identity) do
        create(:external_identity, owner: book, external_resource: :open_library, external_id: 'OL1W')
      end

      before do
        described_class.call(identity)
        identity.update!(external_id: 'OL2W')
      end

      it 'reattaches the link for the new id and enqueues another fetch task' do
        expect { call }.to change(Admin::Tasks::OpenLibraryBookFetch, :count).by(1)
                         .and have_enqueued_job(Admin::DataFetchJob)

        identity.reload
        expect(identity.external_link.url).to eq('https://openlibrary.org/works/OL2W')
      end
    end
  end

  describe '.link_builder_for' do
    it 'returns the book Open Library work builder' do
      expect(described_class.link_builder_for('open_library', ::Book)).to eq(Admin::ExternalLinkBuilders::OpenLibrary::Work)
    end

    it 'returns the author Open Library author builder' do
      expect(described_class.link_builder_for(:open_library, ::Author)).to eq(Admin::ExternalLinkBuilders::OpenLibrary::Author)
    end

    it 'returns the author Wikidata builder' do
      expect(described_class.link_builder_for('wikidata', ::Author)).to eq(Admin::ExternalLinkBuilders::Wikidata)
    end

    it 'returns nil when no builder is defined' do
      expect(described_class.link_builder_for('goodreads', ::Author)).to be_nil
    end
  end
end
