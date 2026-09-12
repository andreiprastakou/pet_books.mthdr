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
end
