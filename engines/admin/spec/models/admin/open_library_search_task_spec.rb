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
    let(:searcher) { instance_double(InfoFetchers::OpenLibrary::Api::BookSearcher) }
    let(:results) do
      [
        { 'key' => '/works/OL1W', 'title' => 'Title A' },
        { 'key' => '/works/OL2W', 'title' => 'Title B' }
      ]
    end

    before do
      allow(InfoFetchers::OpenLibrary::Api::BookSearcher).to receive(:new).with(book).and_return(searcher)
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
      expect(identity.identificator).to eq('OL27448W')
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
      expect(identity.identificator).to eq('OL113611A')
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
end
