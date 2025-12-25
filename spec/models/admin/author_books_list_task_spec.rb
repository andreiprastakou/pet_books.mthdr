# == Schema Information
#
# Table name: admin_data_fetch_tasks
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

RSpec.describe Admin::AuthorBooksListTask do
  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:author_books_list_task)).to be_valid
    end
  end

  describe '.setup' do
    let(:author) { create(:author) }

    it 'creates a new author books list task' do
      expect { described_class.setup(author) }.to change(described_class, :count).by(1)
      new_record = described_class.last
      expect(new_record.target).to eq(author)
      expect(new_record.status).to eq('requested')
    end
  end

  describe '#perform' do
    subject(:call) { task.perform }

    let(:task) { build(:author_books_list_task, target: author) }
    let(:author) { build_stubbed(:author) }
    let(:expert) { instance_double(InfoFetchers::Chats::AuthorBooksListExpert, chat: chat, errors: []) }
    let(:chat) { create(:ai_chat) }
    let(:books_data) do
      [
        { title: 'Book A', original_title: 'Original A', year_published: 2000, literary_form: 'novel', wiki_url: 'https://example.com/a' },
        { title: 'Book B', original_title: nil, year_published: 2001, literary_form: 'novel', wiki_url: nil }
      ]
    end

    before do
      allow(InfoFetchers::Chats::AuthorBooksListExpert).to receive(:new).and_return(expert)
      allow(expert).to receive(:ask_books_list).with(author).and_return(books_data)
    end

    it 'fetches the books list' do
      call
      expect(task.status).to eq('fetched')
      expect(task.fetched_data.to_json).to eq(books_data.to_json)
      expect(task.chat).to eq(chat)
    end

    context 'when there is an error' do
      before do
        allow(expert).to receive(:errors).and_return([StandardError.new('ERROR_X')])
        allow(expert).to receive(:ask_books_list).with(author).and_return([])
      end

      it 'updates the task with the error', :aggregate_failures do
        call
        expect(task.status).to eq('failed')
        expect(task.fetch_error_details).to eq('ERROR_X')
        expect(task.fetched_data).to eq([])
        expect(task.chat).to eq(chat)
      end
    end
  end
end

