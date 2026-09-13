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

RSpec.describe Admin::OpenLibraryAuthorSearchTask do
  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:open_library_author_search_task)).to be_valid
    end
  end

  describe '.setup' do
    let(:author) { create(:author) }

    it 'creates a new open library author search task' do
      expect { described_class.setup(author) }.to change(described_class, :count).by(1)
      new_record = described_class.last
      expect(new_record.target).to eq(author)
      expect(new_record.status).to eq('requested')
      expect(new_record.chat).to be_nil
    end
  end

  describe '#perform' do
    subject(:call) { task.perform }

    let(:task) { create(:open_library_author_search_task, target: author) }
    let(:author) { create(:author) }
    let(:searcher) { instance_double(InfoFetchers::OpenLibrary::Api::AuthorSearcher) }
    let(:results) do
      [
        { 'key' => 'OL26320A', 'name' => 'J. R. R. Tolkien' },
        { 'key' => 'OL2623360A', 'name' => 'Christopher Tolkien' }
      ]
    end

    before do
      allow(InfoFetchers::OpenLibrary::Api::AuthorSearcher).to receive(:new).with(author).and_return(searcher)
      allow(searcher).to receive(:search).and_return(results)
    end

    it 'stores search results on the task' do
      expect(call).to eq(results)
      expect(task.reload.status).to eq('fetched')
      expect(task.fetched_data).to eq(results)
      expect(task.chat).to be_nil
    end
  end

  describe '#add_author_identity!' do
    subject(:call) { task.add_author_identity!(author_key) }

    let(:author) { create(:author) }
    let(:task) { create(:open_library_author_search_task, target: author, status: :fetched) }
    let(:author_key) { '/authors/OL113611A' }

    it 'creates an external identity on the author' do
      expect { call }.to change(author.external_identities, :count).by(1)
      identity = call
      expect(identity.external_resource).to eq('open_library')
      expect(identity.external_id).to eq('OL113611A')
      expect(identity.external_link.url).to eq('https://openlibrary.org/authors/OL113611A')
      expect(task.reload.status).to eq('fetched')
    end

    context 'when author key is invalid' do
      let(:author_key) { 'not-a-key' }

      it 'raises and does not change status' do
        expect { call }.to raise_error(ArgumentError, 'Invalid Open Library author key')
        expect(task.reload.status).to eq('fetched')
      end
    end
  end

  describe '.next_unresolved' do
    let!(:first_task) { create(:open_library_author_search_task, status: :fetched) }
    let!(:second_task) { create(:open_library_author_search_task, status: :fetched) }

    before { create(:open_library_author_search_task, status: :verified) }

    it 'returns the earliest fetched task' do
      expect(described_class.next_unresolved).to eq(first_task)
    end

    it 'can exclude a task' do
      expect(described_class.next_unresolved(excluding: first_task)).to eq(second_task)
    end
  end
end
