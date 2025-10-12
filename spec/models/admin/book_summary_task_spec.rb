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

RSpec.describe Admin::BookSummaryTask, type: :model do
  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:book_summary_task)).to be_valid
    end
  end

  describe '.setup' do
    let(:book) { create(:book) }

    it 'creates a new book summary task' do
      expect { described_class.setup(book) }.to change(described_class, :count).by(1)
      new_record = described_class.last
      expect(new_record.target).to eq(book)
      expect(new_record.status).to eq('requested')
    end
  end

  describe '#perform' do
    subject(:call) { task.perform }

    let(:task) { build(:book_summary_task, target: book) }
    let(:book) { build_stubbed(:book) }
    let(:writer) { instance_double(InfoFetchers::Chats::BookSummaryWriter, chat: chat, errors?: false) }
    let(:chat) { create(:ai_chat) }
    let(:summaries) do
      [
        { 'summary' => 'SUMMARY_A', 'themes' => 'theme_a', 'genre' => 'genre_a', 'src' => 'src_a' },
        { 'summary' => 'SUMMARY_B', 'themes' => 'theme_b', 'genre' => 'genre_b', 'src' => 'src_b' }
      ]
    end

    before do
      allow(InfoFetchers::Chats::BookSummaryWriter).to receive(:new).and_return(writer)
      allow(writer).to receive(:ask).with(book).and_return(summaries)
    end

    it 'fetches the summary' do
      expect(call).to eq(summaries)
      expect(task.status).to eq('fetched')
      expect(task.fetched_data).to eq(summaries)
      expect(task.chat).to eq(chat)
    end

    context 'when there is an error' do
      before do
        allow(writer).to receive(:errors?).and_return(true)
        allow(writer).to receive(:errors).and_return([StandardError.new('ERROR_X')])
        allow(writer).to receive(:ask).with(book).and_return([])
      end

      it 'updates the task with the error', :aggregate_failures do
        expect(call).to eq([])
        expect(task.status).to eq('failed')
        expect(task.fetch_error_details).to eq('ERROR_X')
        expect(task.fetched_data).to eq([])
        expect(task.chat).to eq(chat)
      end
    end
  end
end
