# == Schema Information
#
# Table name: admin_data_fetch_tasks
# Database name: primary
#
#  id                  :integer          not null, primary key
#  fetch_error_details :string
#  fetched_data        :json
#  input_data          :json
#  status              :string           not null
#  target_type         :string           not null
#  type                :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  chat_id             :integer
#  target_id           :integer          not null
#
# Indexes
#
#  index_admin_data_fetch_tasks_on_chat_id  (chat_id)
#  index_admin_data_fetch_tasks_on_target   (target_type,target_id)
#
# Foreign Keys
#
#  chat_id  (chat_id => ai_chats.id)
#
require 'rails_helper'

RSpec.describe Admin::OpenLibraryFetchTask do
  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:open_library_fetch_task)).to be_valid
    end
  end

  describe '.setup' do
    let(:external_identity) { create(:external_identity) }

    it 'creates a new open library fetch task' do
      expect { described_class.setup(external_identity) }.to change(described_class, :count).by(1)
      new_record = described_class.last
      expect(new_record.target).to eq(external_identity)
      expect(new_record.status).to eq('requested')
      expect(new_record.chat).to be_nil
    end
  end

  describe '#perform' do
    subject(:call) { task.perform }

    let(:task) { create(:open_library_fetch_task, target: external_identity) }
    let(:external_identity) { create(:external_identity) }
    let(:fetcher) { instance_double(InfoFetchers::OpenLibrary::BookExternalDataFetcher) }
    let(:api_data) { { 'key' => '/works/OL27448W', 'title' => 'The Lord of the Rings' } }
    let(:fetch_record) { create(:external_data_fetch, external_identity: external_identity, data: api_data) }

    before do
      allow(InfoFetchers::OpenLibrary::BookExternalDataFetcher)
        .to receive(:new).with(external_identity).and_return(fetcher)
      allow(fetcher).to receive(:fetch!).and_return(fetch_record)
    end

    it 'stores fetched data on the task' do
      call
      expect(task.reload.status).to eq('fetched')
      expect(task.fetched_data).to eq(api_data)
    end

    context 'when the fetch fails' do
      before { allow(fetcher).to receive(:fetch!).and_return(nil) }

      it 'marks the task as failed' do
        call
        expect(task.reload.status).to eq('failed')
        expect(task.fetch_error_details).to eq('Failed to fetch Open Library work data')
      end
    end
  end

  describe '#book' do
    let(:book) { create(:book) }
    let(:external_identity) { create(:external_identity, owner: book) }
    let(:task) { create(:open_library_fetch_task, target: external_identity) }

    it 'returns the external identity owner book' do
      expect(task.book).to eq(book)
    end

    context 'when the owner is not a book' do
      let(:external_identity) { create(:external_identity, owner: create(:author)) }

      it 'raises' do
        expect { task.book }.to raise_error(ArgumentError, 'Open Library fetch target must belong to a book')
      end
    end
  end

  describe '#fetched_identifiers' do
    let(:task) { build(:open_library_fetch_task, fetched_data: fetched_data) }
    let(:fetched_data) do
      {
        'identifiers' => {
          'wikidata' => ['Q137179018'],
          'goodreads' => ['87596585'],
          'librarything' => ['33363109'],
          'isfdb' => ['3537436']
        }
      }
    end

    it 'returns allowed identifier pairs and skips unknown resources' do
      expect(task.fetched_identifiers).to eq(
        [
          ['wikidata', 'Q137179018'],
          ['goodreads', '87596585'],
          ['librarything', '33363109']
        ]
      )
    end
  end

  describe '#fetched_description' do
    let(:task) { build(:open_library_fetch_task, fetched_data: fetched_data) }

    context 'when description is a typed text object' do
      let(:fetched_data) { { 'description' => { 'type' => '/type/text', 'value' => 'An epic fantasy novel.' } } }

      it 'returns the value' do
        expect(task.fetched_description).to eq('An epic fantasy novel.')
      end
    end

    context 'when description is a string' do
      let(:fetched_data) { { 'description' => 'Plain description' } }

      it 'returns the string' do
        expect(task.fetched_description).to eq('Plain description')
      end
    end
  end

  describe '#add_identity!' do
    subject(:call) { task.add_identity!('wikidata', 'Q137179018') }

    let(:book) { create(:book) }
    let(:external_identity) { create(:external_identity, owner: book) }
    let(:task) { create(:open_library_fetch_task, target: external_identity) }

    it 'creates an external identity on the book' do
      expect { call }.to change(book.external_identities, :count).by(1)
      identity = book.external_identities.find_by!(external_resource: :wikidata)
      expect(identity.identificator).to eq('Q137179018')
      expect(identity.url).to eq('https://www.wikidata.org/wiki/Q137179018')
    end
  end

  describe '#apply_summary!' do
    subject(:call) { task.apply_summary!('Updated summary from Open Library') }

    let(:book) { create(:book, summary: 'Old summary') }
    let(:external_identity) { create(:external_identity, owner: book) }
    let(:task) { create(:open_library_fetch_task, target: external_identity) }

    it 'updates the book summary' do
      call
      expect(book.reload.summary).to eq('Updated summary from Open Library')
    end
  end
end
