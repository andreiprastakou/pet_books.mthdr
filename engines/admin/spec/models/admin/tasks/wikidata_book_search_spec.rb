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

RSpec.describe Admin::Tasks::WikidataBookSearch do
  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:wikidata_search_task)).to be_valid
    end
  end

  describe '.setup' do
    let(:book) { create(:book) }

    it 'creates a new wikidata search task' do
      expect { described_class.setup(book) }.to change(described_class, :count).by(1)
      new_record = described_class.last
      expect(new_record.target).to eq(book)
      expect(new_record.status).to eq('requested')
      expect(new_record.chat).to be_nil
    end
  end

  describe '#perform' do
    subject(:call) { task.perform }

    let(:task) { create(:wikidata_search_task, target: book) }
    let(:book) { create(:book) }
    let(:searcher) { instance_double(Admin::InfoFetchers::Wikidata::Api::BookSearcher) }
    let(:results) do
      [
        { 'id' => 'Q1', 'display-label' => { 'language' => 'en', 'value' => 'Title A' } },
        { 'id' => 'Q2', 'display-label' => { 'language' => 'en', 'value' => 'Title B' } }
      ]
    end

    before do
      allow(Admin::InfoFetchers::Wikidata::Api::BookSearcher).to receive(:new).with(book).and_return(searcher)
      allow(searcher).to receive(:search).and_return(results)
    end

    it 'stores search results on the task' do
      expect(call).to eq(results)
      expect(task.reload.status).to eq('fetched')
      expect(task.fetched_data).to eq(results)
      expect(task.chat).to be_nil
    end
  end

  describe '#fetched_data_normalized' do
    let(:task) { build(:wikidata_search_task, fetched_data: fetched_data) }
    let(:fetched_data) do
      JSON.parse(
        Rails.root.join(
          'engines/admin/spec/fixtures/wikidata/book_search_in_the_slopes.json'
        ).read
      )
    end

    it 'returns external_id, title, and description for each result' do
      expect(task.fetched_data_normalized).to eq(
        [
          {
            'external_id' => 'Q80182620',
            'title' => 'In the Slopes',
            'description' => 'short story by China Miéville'
          }
        ]
      )
    end

    context 'when fetched_data is blank' do
      let(:fetched_data) { nil }

      it 'returns an empty array' do
        expect(task.fetched_data_normalized).to eq([])
      end
    end
  end

  describe '#add_work_identity!' do
    subject(:call) { task.add_work_identity!(entity_id) }

    let(:task) { create(:wikidata_search_task, target: book, status: :fetched) }
    let(:book) { create(:book) }
    let(:entity_id) { '/wiki/Q74287' }

    it 'creates an external identity without changing task status' do
      expect { call }.to change(book.external_identities, :count).by(1)
      identity = call
      expect(identity).to have_attributes(
        external_resource: 'wikidata',
        external_id: 'Q74287'
      )
      expect(identity.external_link.url).to eq('https://www.wikidata.org/wiki/Q74287')
      expect(task.reload.status).to eq('fetched')
    end

    context 'when entity id is invalid' do
      let(:entity_id) { 'not-a-qid' }

      it 'raises and does not change status' do
        expect { call }.to raise_error(ArgumentError, 'Invalid Wikidata entity id')
        expect(task.reload.status).to eq('fetched')
      end
    end
  end

  describe '#add_author_identity!' do
    subject(:call) { task.add_author_identity!(entity_id, author: author) }

    let(:author) { create(:author) }
    let(:book) { create(:book, authors: [author]) }
    let(:task) { create(:wikidata_search_task, target: book, status: :fetched) }
    let(:entity_id) { '/wiki/Q892' }

    it 'creates an external identity on the author' do
      expect { call }.to change(author.external_identities, :count).by(1)
      identity = call
      expect(identity).to have_attributes(
        external_resource: 'wikidata',
        external_id: 'Q892'
      )
      expect(identity.external_link.url).to eq('https://www.wikidata.org/wiki/Q892')
      expect(task.reload.status).to eq('fetched')
    end

    context 'when author is not linked to the book' do
      subject(:call) { task.add_author_identity!(entity_id, author: other_author) }

      let(:other_author) { create(:author) }

      it 'raises' do
        expect { call }.to raise_error(ArgumentError, 'Author is not linked to this book')
      end
    end

    context 'when entity id is invalid' do
      let(:entity_id) { 'not-a-qid' }

      it 'raises' do
        expect { call }.to raise_error(ArgumentError, 'Invalid Wikidata entity id')
      end
    end
  end

  describe '.next_unresolved' do
    let!(:first_task) { create(:wikidata_search_task, status: :fetched) }
    let!(:second_task) { create(:wikidata_search_task, status: :fetched) }

    before { create(:wikidata_search_task, status: :verified) }

    it 'returns the earliest fetched task' do
      expect(described_class.next_unresolved).to eq(first_task)
    end

    it 'can exclude a task' do
      expect(described_class.next_unresolved(excluding: first_task)).to eq(second_task)
    end
  end
end
