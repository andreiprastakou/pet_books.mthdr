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

RSpec.describe Admin::Tasks::OpenLibraryAuthorFetch do
  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:open_library_author_fetch_task)).to be_valid
    end
  end

  describe '.setup' do
    let!(:external_identity) { create(:external_identity, owner: create(:author), external_id: 'OL1394865A') }

    it 'creates a new open library author fetch task' do
      expect { described_class.setup(external_identity) }.to change(described_class, :count).by(1)
      new_record = described_class.last
      expect(new_record.target).to eq(external_identity)
      expect(new_record.status).to eq('requested')
      expect(new_record.chat).to be_nil
    end
  end

  describe '#perform' do
    subject(:call) { task.perform }

    let(:author) { create(:author) }
    let(:external_identity) do
      create(:external_identity, owner: author, external_id: 'OL1394865A')
    end
    let(:task) { create(:open_library_author_fetch_task, target: external_identity) }
    let(:fetcher) { instance_double(Admin::InfoFetchers::OpenLibrary::Api::AuthorDetailsFetcher) }
    let(:api_data) { { 'key' => '/authors/OL1394865A', 'name' => 'J. R. R. Tolkien' } }

    before do
      allow(Admin::InfoFetchers::OpenLibrary::Api::AuthorDetailsFetcher)
        .to receive(:new).with(external_identity.external_id).and_return(fetcher)
      allow(fetcher).to receive(:fetch).and_return(api_data)
    end

    it 'stores fetched data on the task' do
      call
      expect(task.reload.status).to eq('fetched')
      expect(task.fetched_data).to eq(api_data)
    end

    context 'when the fetch fails' do
      before { allow(fetcher).to receive(:fetch).and_return(nil) }

      it 'marks the task as failed' do
        call
        expect(task.reload.status).to eq('failed')
        expect(task.fetch_error_details).to eq('Failed to fetch Open Library author data')
      end
    end
  end

  describe '#author' do
    let(:author) { create(:author) }
    let(:external_identity) { create(:external_identity, owner: author, external_id: 'OL1394865A') }
    let(:task) { create(:open_library_author_fetch_task, target: external_identity) }

    it 'returns the external identity owner author' do
      expect(task.author).to eq(author)
    end

    context 'when the owner is not an author' do
      let(:external_identity) { create(:external_identity, owner: create(:book)) }

      it 'raises' do
        expect { task.author }.to raise_error(
          ArgumentError,
          'Open Library author fetch target must belong to an author'
        )
      end
    end
  end

  describe '#fetched_data_normalized' do
    let(:task) { build(:open_library_author_fetch_task, fetched_data: fetched_data) }
    let(:fetched_data) do
      {
        'name' => 'J. R. R. Tolkien',
        'personal_name' => 'John Ronald Reuel Tolkien',
        'birth_date' => '3 January 1892',
        'death_date' => '2 September 1973',
        'bio' => { 'type' => '/type/text', 'value' => 'English writer and philologist.' },
        'remote_ids' => {
          'viaf' => '95218067',
          'wikidata' => 'Q892',
          'goodreads' => ''
        },
        'links' => [
          { 'title' => 'Wikipedia', 'url' => 'https://en.wikipedia.org/wiki/J._R._R._Tolkien' },
          { 'title' => 'Missing url' },
          'not-a-hash'
        ],
        'photos' => [6425004, 'not-an-int', nil],
        'revision' => 12,
        'key' => '/authors/OL26320A',
        'alternate_names' => ['JRR Tolkien']
      }
    end

    it 'returns usable fields with mapped remote ids and links' do
      expect(task.fetched_data_normalized).to eq(
        {
          'name' => 'J. R. R. Tolkien',
          'personal_name' => 'John Ronald Reuel Tolkien',
          'birth_date' => '3 January 1892',
          'death_date' => '2 September 1973',
          'bio' => 'English writer and philologist.',
          'remote_ids' => [
            { 'external_resource' => 'viaf', 'external_id' => '95218067' },
            { 'external_resource' => 'wikidata', 'external_id' => 'Q892' }
          ],
          'links' => [
            { 'label' => 'Wikipedia', 'url' => 'https://en.wikipedia.org/wiki/J._R._R._Tolkien' }
          ],
          'photos' => [6_425_004],
          'revision' => 12
        }
      )
    end

    context 'when fetched_data is nil' do
      let(:fetched_data) { nil }

      it 'returns an empty hash' do
        expect(task.fetched_data_normalized).to eq({})
      end
    end

    context 'when fetched_data is not a hash' do
      let(:fetched_data) { ['not', 'a', 'hash'] }

      it 'returns an empty hash' do
        expect(task.fetched_data_normalized).to eq({})
      end
    end

    context 'when nested collections are malformed' do
      let(:fetched_data) do
        {
          'name' => 'Broken Author',
          'remote_ids' => ['not-a-hash'],
          'links' => { 'url' => 'https://example.com' },
          'photos' => '6425004'
        }
      end

      it 'treats invalid collections as empty and drops them' do
        expect(task.fetched_data_normalized).to eq(
          {
            'name' => 'Broken Author'
          }
        )
      end
    end

    context 'with a lifelike Open Library author fetch fixture' do
      let(:fetched_data) do
        JSON.parse(
          File.read(
            Rails.root.join(
              'engines/admin/spec/fixtures/open_library/author_fetch_dean_koontz.json'
            )
          )
        )
      end

      it 'extracts usable values from the real-shaped payload' do
        expect(task.fetched_data_normalized).to eq(
          {
            'name' => 'Dean Koontz',
            'personal_name' => 'Dean R. Koontz',
            'birth_date' => '9 July 1945',
            'bio' => fetched_data['bio'],
            'remote_ids' => [
              { 'external_resource' => 'viaf', 'external_id' => '110880758' },
              { 'external_resource' => 'goodreads', 'external_id' => '9355' },
              { 'external_resource' => 'isni', 'external_id' => '0000000120327893' },
              { 'external_resource' => 'amazon', 'external_id' => 'B000APG4T6' },
              { 'external_resource' => 'librarything', 'external_id' => 'koontzdean' },
              { 'external_resource' => 'wikidata', 'external_id' => 'Q272076' }
            ],
            'links' => [
              { 'label' => 'Official Web Site', 'url' => 'http://www.deankoontz.com/' },
              { 'label' => 'Dean Koontz Books in Order', 'url' => 'https://www.littlestack.com/author/dean-koontz' }
            ],
            'photos' => [6_425_004],
            'revision' => 37
          }
        )
      end
    end
  end
end
