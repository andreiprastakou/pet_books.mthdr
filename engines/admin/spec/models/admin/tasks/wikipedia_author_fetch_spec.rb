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

RSpec.describe Admin::Tasks::WikipediaAuthorFetch do
  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:wikipedia_author_fetch_task)).to be_valid
    end
  end

  describe '.setup' do
    let(:author) { create(:author) }

    it 'creates a new wikipedia author fetch task' do
      expect { described_class.setup(author) }.to change(described_class, :count).by(1)
      new_record = described_class.last
      expect(new_record.target).to eq(author)
      expect(new_record.status).to eq('requested')
      expect(new_record.chat).to be_nil
    end
  end

  describe '#perform' do
    subject(:call) { task.perform }

    let(:author) { create(:author, wiki_url: 'https://sk.wikipedia.org/wiki/Seneca') }
    let(:task) { create(:wikipedia_author_fetch_task, target: author) }
    let(:fetcher) { instance_double(Admin::InfoFetchers::Wikipedia::Api::Fetcher) }
    let(:api_data) do
      {
        'batchcomplete' => true,
        'query' => {
          'pages' => [
            {
              'pageid' => 1,
              'ns' => 0,
              'title' => 'Seneca',
              'extract' => 'Lucius Annaeus Seneca was a Roman Stoic philosopher.'
            }
          ]
        }
      }
    end

    before do
      allow(Admin::InfoFetchers::Wikipedia::Api::Fetcher)
        .to receive(:new).with(language: 'sk').and_return(fetcher)
      allow(fetcher).to receive(:fetch_intro).with('Seneca').and_return(api_data)
    end

    it 'stores fetched data on the task' do
      call
      expect(task.reload.status).to eq('fetched')
      expect(task.fetched_data).to eq(api_data)
    end

    context 'when the author has no wikipedia url' do
      let(:author) { create(:author) }

      it 'marks the task as failed' do
        call
        expect(task.reload.status).to eq('failed')
        expect(task.fetch_error_details).to eq('Wikipedia URL is missing or invalid')
        expect(Admin::InfoFetchers::Wikipedia::Api::Fetcher).not_to have_received(:new)
      end
    end

    context 'when the fetch fails' do
      before { allow(fetcher).to receive(:fetch_intro).and_return(nil) }

      it 'marks the task as failed' do
        call
        expect(task.reload.status).to eq('failed')
        expect(task.fetch_error_details).to eq('Failed to fetch Wikipedia page intro')
      end
    end
  end

  describe '#author' do
    let(:author) { create(:author) }
    let(:task) { create(:wikipedia_author_fetch_task, target: author) }

    it 'returns the target author' do
      expect(task.author).to eq(author)
    end
  end

  describe '#fetched_data_normalized' do
    let(:task) { build(:wikipedia_author_fetch_task, fetched_data: fetched_data) }

    context 'when the page has an extract' do
      let(:fetched_data) do
        {
          'query' => {
            'pages' => [
              { 'title' => 'Seneca', 'extract' => 'A Roman Stoic philosopher.' }
            ]
          }
        }
      end

      it 'returns the description' do
        expect(task.fetched_data_normalized).to eq('description' => 'A Roman Stoic philosopher.')
      end
    end

    context 'when the page is missing' do
      let(:fetched_data) do
        {
          'query' => {
            'pages' => [{ 'title' => 'Missing Author', 'missing' => true }]
          }
        }
      end

      it 'returns an empty hash' do
        expect(task.fetched_data_normalized).to eq({})
      end
    end
  end
end
