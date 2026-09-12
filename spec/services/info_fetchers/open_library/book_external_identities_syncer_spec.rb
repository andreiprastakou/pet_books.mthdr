require 'rails_helper'

RSpec.describe InfoFetchers::OpenLibrary::BookExternalIdentitiesSyncer do
  describe '#sync!' do
    subject(:call) { described_class.new(external_data_fetch, book).sync! }

    let(:book) { create(:book) }
    let(:open_library_identity) do
      create(:external_identity, owner: book, external_resource: :open_library, identificator: 'OL1W')
    end
    let(:external_data_fetch) do
      create(
        :external_data_fetch,
        external_identity: open_library_identity,
        data: {
          'title' => 'Example',
          'identifiers' => {
            'wikidata' => ['Q137179018'],
            'goodreads' => ['87596585'],
            'librarything' => ['33363109'],
            'isfdb' => ['3537436']
          }
        }
      )
    end

    before { external_data_fetch }

    it 'creates ExternalIdentity entries for allowed identifier resources' do
      expect { call }.to change(book.external_identities, :count).by(3)

      expect(book.external_identities.find_by(external_resource: :wikidata).identificator).to eq('Q137179018')
      expect(book.external_identities.find_by(external_resource: :goodreads).identificator).to eq('87596585')
      expect(book.external_identities.find_by(external_resource: :librarything).identificator).to eq('33363109')
    end

    it 'skips resources not present in the enum' do
      call
      expect(book.external_identities.where(identificator: '3537436')).not_to exist
    end

    context 'when the book already has an identity for a resource' do
      before do
        create(:external_identity, owner: book, external_resource: :goodreads, identificator: 'existing-gr')
      end

      it 'does not replace or duplicate existing resources' do
        expect { call }.to change(book.external_identities, :count).by(2)
        expect(book.external_identities.find_by(external_resource: :goodreads).identificator).to eq('existing-gr')
      end
    end

    context 'when identifiers are missing' do
      before { external_data_fetch.update!(data: { 'title' => 'Example' }) }

      it 'does not create identities' do
        expect { call }.not_to change(ExternalIdentity, :count)
      end
    end

    context 'when an identifier value is blank' do
      before do
        external_data_fetch.update!(
          data: { 'identifiers' => { 'wikidata' => ['', nil], 'goodreads' => ['87596585'] } }
        )
      end

      it 'skips blank values and creates the rest' do
        expect { call }.to change(book.external_identities, :count).by(1)
        expect(book.external_identities.find_by(external_resource: :goodreads).identificator).to eq('87596585')
        expect(book.external_identities.find_by(external_resource: :wikidata)).to be_nil
      end
    end
  end
end
