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

RSpec.describe Admin::Tasks::BaseTask do
  it { is_expected.to belong_to(:chat).class_name(Admin::Ai::Chat.name).optional }
  it { is_expected.to belong_to(:target) }

  specify do
    expect(described_class.new).to define_enum_for(:status)
      .with_values(
        requested: 'requested', fetched: 'fetched', failed: 'failed', rejected: 'rejected', verified: 'verified'
      )
      .with_default(:requested)
      .backed_by_column_of_type(:string)
  end

  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:base_admin_data_fetch_task)).to be_valid
    end
  end

  describe '#fetched_data_normalized' do
    it 'returns an empty hash by default' do
      expect(described_class.new.fetched_data_normalized).to eq({})
    end
  end

  describe '#save_results!' do
    let(:task) { create(:open_library_book_search_task) }

    it 'marks the task fetched when normalized data is present' do
      task.save_results!([{ 'key' => '/works/OL1W', 'title' => 'Title' }])
      expect(task.reload.status).to eq('fetched')
      expect(task.fetched_data).to eq([{ 'key' => '/works/OL1W', 'title' => 'Title' }])
    end

    it 'marks the task rejected when normalized data is blank' do
      task.save_results!([])
      expect(task.reload.status).to eq('rejected')
      expect(task.fetched_data).to eq([])
    end

    it 'marks the task failed when errors are present' do
      task.save_results!(nil, errors: [StandardError.new('boom')])
      expect(task.reload.status).to eq('failed')
      expect(task.fetch_error_details).to eq('boom')
    end
  end

  describe '#review_subject' do
    it 'returns the book for a book-targeted task' do
      book = create(:book)
      task = create(:wikipedia_book_fetch_task, target: book)
      expect(task.review_subject).to eq(Admin::Book.cast(book))
    end

    it 'returns the author for an author-targeted task' do
      author = create(:author)
      task = create(:wikipedia_author_fetch_task, target: author)
      expect(task.review_subject).to eq(Admin::Author.cast(author))
    end

    it 'returns the owner book for an external-identity-targeted task' do
      book = create(:book)
      identity = create(:external_identity, owner: book, external_resource: :wikidata, external_id: 'Q1')
      task = create(:wikidata_fetch_task, target: identity)
      expect(task.review_subject).to eq(Admin::Book.cast(book))
    end
  end

  describe '.pending_review_tasks_for' do
    let(:book) { create(:book) }

    it 'orders fetched tasks by source then fetch-before-search' do
      library_thing = create(:library_thing_search_task, target: book, status: :fetched)
      open_library_search = create(:open_library_book_search_task, target: book, status: :fetched)
      wikidata_search = create(:wikidata_search_task, target: book, status: :fetched)
      wikipedia = create(:wikipedia_book_fetch_task, target: book, status: :fetched)
      identity = create(:external_identity, owner: book, external_resource: :open_library, external_id: 'OL1W')
      open_library_fetch = create(:open_library_book_fetch_task, target: identity, status: :fetched)
      create(:wikidata_search_task, target: book, status: :requested)
      create(:book_summary_task, target: book, status: :fetched)

      expect(described_class.pending_review_tasks_for(book)).to eq(
        [wikipedia, wikidata_search, open_library_fetch, open_library_search, library_thing]
      )
    end

    it 'returns the first pending review task via .next_pending_review_for' do
      create(:open_library_book_search_task, target: book, status: :fetched)
      wikipedia = create(:wikipedia_book_fetch_task, target: book, status: :fetched)

      expect(described_class.next_pending_review_for(book)).to eq(wikipedia)
      expect(described_class.next_pending_review_for(book, excluding: wikipedia)).to be_a(Admin::Tasks::OpenLibraryBookSearch)
    end
  end
end
