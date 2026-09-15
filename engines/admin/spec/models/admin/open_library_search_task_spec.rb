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

RSpec.describe Admin::OpenLibrarySearchTask do
  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:open_library_search_task)).to be_valid
    end
  end

  describe '.setup' do
    let(:book) { create(:book) }

    it 'creates a new open library search task' do
      expect { described_class.setup(book) }.to change(described_class, :count).by(1)
      new_record = described_class.last
      expect(new_record.target).to eq(book)
      expect(new_record.status).to eq('requested')
      expect(new_record.chat).to be_nil
    end
  end

  describe '#perform' do
    subject(:call) { task.perform }

    let(:task) { create(:open_library_search_task, target: book) }
    let(:book) { create(:book) }
    let(:searcher) { instance_double(Admin::InfoFetchers::OpenLibrary::Api::BookSearcher) }
    let(:results) do
      [
        { 'key' => '/works/OL1W', 'title' => 'Title A' },
        { 'key' => '/works/OL2W', 'title' => 'Title B' }
      ]
    end

    before do
      allow(Admin::InfoFetchers::OpenLibrary::Api::BookSearcher).to receive(:new).with(book).and_return(searcher)
      allow(searcher).to receive(:search).and_return(results)
    end

    it 'stores search results on the task' do
      expect(call).to eq(results)
      expect(task.reload.status).to eq('fetched')
      expect(task.fetched_data).to eq(results)
      expect(task.chat).to be_nil
    end
  end

  describe '#add_work_identity!' do
    subject(:call) { task.add_work_identity!(work_key) }

    let(:task) { create(:open_library_search_task, target: book, status: :fetched) }
    let(:book) { create(:book) }
    let(:work_key) { '/works/OL27448W' }

    it 'creates an external identity without changing task status' do
      expect { call }.to change(book.external_identities, :count).by(1)
      identity = call
      expect(identity.external_resource).to eq('open_library')
      expect(identity.external_id).to eq('OL27448W')
      expect(identity.external_link.url).to eq('https://openlibrary.org/works/OL27448W')
      expect(task.reload.status).to eq('fetched')
    end

    context 'when work key is invalid' do
      let(:work_key) { 'not-a-key' }

      it 'raises and does not change status' do
        expect { call }.to raise_error(ArgumentError, 'Invalid Open Library work key')
        expect(task.reload.status).to eq('fetched')
      end
    end
  end

  describe '#add_author_identity!' do
    subject(:call) { task.add_author_identity!(author_key, author: author) }

    let(:author) { create(:author) }
    let(:book) { create(:book, authors: [author]) }
    let(:task) { create(:open_library_search_task, target: book, status: :fetched) }
    let(:author_key) { '/authors/OL113611A' }

    it 'creates an external identity on the author' do
      expect { call }.to change(author.external_identities, :count).by(1)
      identity = call
      expect(identity.external_resource).to eq('open_library')
      expect(identity.external_id).to eq('OL113611A')
      expect(identity.external_link.url).to eq('https://openlibrary.org/authors/OL113611A')
      expect(task.reload.status).to eq('fetched')
    end

    context 'when author is not linked to the book' do
      subject(:call) { task.add_author_identity!(author_key, author: other_author) }

      let(:other_author) { create(:author) }

      it 'raises' do
        expect { call }.to raise_error(ArgumentError, 'Author is not linked to this book')
      end
    end

    context 'when author key is invalid' do
      let(:author_key) { 'not-a-key' }

      it 'raises' do
        expect { call }.to raise_error(ArgumentError, 'Invalid Open Library author key')
      end
    end
  end

  describe '.next_unresolved' do
    let!(:first_task) { create(:open_library_search_task, status: :fetched) }
    let!(:second_task) { create(:open_library_search_task, status: :fetched) }

    before { create(:open_library_search_task, status: :verified) }

    it 'returns the earliest fetched task' do
      expect(described_class.next_unresolved).to eq(first_task)
    end

    it 'can exclude a task' do
      expect(described_class.next_unresolved(excluding: first_task)).to eq(second_task)
    end
  end

  describe '#fetched_usable_values' do
    let(:task) { build(:open_library_search_task, fetched_data: fetched_data) }
    let(:fetched_data) do
      [
        {
          'key' => '/works/OL1W',
          'title' => 'Title A',
          'first_publish_year' => 1967,
          'author_key' => %w[OL113611A OL113612A],
          'author_name' => ['Jules Verne', 'Other Author'],
          'cover_i' => 123,
          'edition_count' => 4
        }
      ]
    end

    it 'returns usable fields with paired authors' do
      expect(task.fetched_usable_values).to eq(
        [
          {
            'external_id' => '/works/OL1W',
            'title' => 'Title A',
            'first_publish_year' => 1967,
            'authors' => [
              { 'external_id' => 'OL113611A', 'name' => 'Jules Verne' },
              { 'external_id' => 'OL113612A', 'name' => 'Other Author' }
            ]
          }
        ]
      )
    end

    context 'when fetched_data is blank' do
      let(:fetched_data) { nil }

      it 'returns an empty array' do
        expect(task.fetched_usable_values).to eq([])
      end
    end

    context 'when fetched_data is not an array' do
      let(:fetched_data) { { 'key' => '/works/OL1W' } }

      it 'returns an empty array' do
        expect(task.fetched_usable_values).to eq([])
      end
    end

    context 'when entries are malformed' do
      let(:fetched_data) do
        [
          'not-a-hash',
          {
            'key' => '/works/OL2W',
            'title' => 'Title B',
            'author_key' => 'OL113611A',
            'author_name' => ['Jules Verne']
          },
          {
            'key' => '/works/OL3W',
            'title' => 'Title C',
            'author_key' => ['OL113611A', nil, ''],
            'author_name' => ['Jules Verne']
          },
          {
            'key' => nil,
            'title' => nil,
            'first_publish_year' => nil,
            'author_key' => []
          }
        ]
      end

      it 'skips invalid entries and tolerates bad author collections' do
        expect(task.fetched_usable_values).to eq(
          [
            {
              'external_id' => '/works/OL2W',
              'title' => 'Title B'
            },
            {
              'external_id' => '/works/OL3W',
              'title' => 'Title C',
              'authors' => [
                { 'external_id' => 'OL113611A', 'name' => 'Jules Verne' }
              ]
            }
          ]
        )
      end
    end

    context 'when author names are missing' do
      let(:fetched_data) do
        [
          {
            'key' => '/works/OL4W',
            'title' => 'Title D',
            'author_key' => %w[OL1A OL2A],
            'author_name' => ['Only One Name']
          }
        ]
      end

      it 'keeps authors without paired names' do
        expect(task.fetched_usable_values).to eq(
          [
            {
              'external_id' => '/works/OL4W',
              'title' => 'Title D',
              'authors' => [
                { 'external_id' => 'OL1A', 'name' => 'Only One Name' },
                { 'external_id' => 'OL2A' }
              ]
            }
          ]
        )
      end
    end

    context 'with a lifelike Open Library search fixture' do
      let(:fetched_data) do
        JSON.parse(
          File.read(
            Rails.root.join(
              'engines/admin/spec/fixtures/open_library/work_search_spy_who_loved_me.json'
            )
          )
        )
      end

      it 'extracts usable values from the real-shaped payload' do
        expect(task.fetched_usable_values).to eq(
          [
            {
              'external_id' => '/works/OL85742W',
              'title' => 'The Spy Who Loved Me',
              'first_publish_year' => 1962,
              'authors' => [{ 'external_id' => 'OL29227A', 'name' => 'Ian Fleming' }]
            },
            {
              'external_id' => '/works/OL19026542W',
              'title' => 'The Spy Who Love Me',
              'authors' => [{ 'external_id' => 'OL29227A', 'name' => 'Ian Fleming' }]
            },
            {
              'external_id' => '/works/OL19677509W',
              'title' => 'Thunderball / For Your Eyes Only / The Spy Who Loved Me',
              'first_publish_year' => 1965,
              'authors' => [{ 'external_id' => 'OL29227A', 'name' => 'Ian Fleming' }]
            },
            {
              'external_id' => '/works/OL38652797W',
              'title' => "Thunderball / The Spy Who Loved Me / On Her Majesty's Secret Service",
              'first_publish_year' => 2024,
              'authors' => [{ 'external_id' => 'OL29227A', 'name' => 'Ian Fleming' }]
            },
            {
              'external_id' => '/works/OL26442941W',
              'title' => 'Live and Let Die / Dr. No / Thunderball / The Spy Who Loved Me',
              'first_publish_year' => 2002,
              'authors' => [{ 'external_id' => 'OL29227A', 'name' => 'Ian Fleming' }]
            },
            {
              'external_id' => '/works/OL19033855W',
              'title' => 'Diamonds are forever / Doctor No / Goldfinger / For your eyes only / The spy who loved me',
              'first_publish_year' => 1993,
              'authors' => [{ 'external_id' => 'OL29227A', 'name' => 'Ian Fleming' }]
            }
          ]
        )
      end
    end
  end
end
