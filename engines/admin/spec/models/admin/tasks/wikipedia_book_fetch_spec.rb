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

RSpec.describe Admin::Tasks::WikipediaBookFetch do
  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:wikipedia_book_fetch_task)).to be_valid
    end
  end

  describe '.setup' do
    let(:book) { create(:book) }

    it 'creates a new wikipedia book fetch task' do
      expect { described_class.setup(book) }.to change(described_class, :count).by(1)
      new_record = described_class.last
      expect(new_record.target).to eq(book)
      expect(new_record.status).to eq('requested')
      expect(new_record.chat).to be_nil
    end
  end

  describe '#perform' do
    subject(:call) { task.perform }

    let(:book) { create(:book, wiki_url: 'https://en.wikipedia.org/wiki/Medea_(Seneca)') }
    let(:task) { create(:wikipedia_book_fetch_task, target: book) }
    let(:fetcher) { instance_double(Admin::InfoFetchers::Wikipedia::Api::Fetcher) }
    let(:api_data) do
      {
        'batchcomplete' => true,
        'query' => {
          'pages' => [
            {
              'pageid' => 28_103_851,
              'ns' => 0,
              'title' => 'Medea (Seneca)',
              'extract' => 'Medea is a fabula crepidata written by Seneca the Younger.'
            }
          ]
        }
      }
    end

    before do
      allow(Admin::InfoFetchers::Wikipedia::Api::Fetcher)
        .to receive(:new).with(language: 'en').and_return(fetcher)
      allow(fetcher).to receive(:fetch_intro).with('Medea_(Seneca)').and_return(api_data)
    end

    it 'stores fetched data on the task' do
      call
      expect(task.reload.status).to eq('fetched')
      expect(task.fetched_data).to eq(api_data)
    end

    context 'when the book has no wikipedia url' do
      let(:book) { create(:book) }

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

  describe '#book' do
    let(:book) { create(:book) }
    let(:task) { create(:wikipedia_book_fetch_task, target: book) }

    it 'returns the target book' do
      expect(task.book).to eq(book)
    end
  end

  describe '#apply_summary!' do
    subject(:call) { task.apply_summary!('Updated summary from Wikipedia') }

    let(:book) { create(:book) }
    let(:task) { create(:wikipedia_book_fetch_task, target: book) }

    it 'upserts a book description for the task source' do
      call
      description = book.reload.description_for_source(task)
      expect(description.text).to eq('Updated summary from Wikipedia')
      expect(description.source_label).to be_nil
      expect(description.source_type).to eq(task.class.name)
      expect(description.source_id).to eq(task.id)
    end

    context 'when a description for the source type already exists' do
      before do
        create(
          :description,
          owner: book,
          text: 'Old summary',
          source_label: 'Wikipedia',
          source_type: task.class.name,
          source_id: task.id
        )
      end

      it 'updates the existing description and clears source_label' do
        expect { call }.not_to change(Description, :count)
        description = book.reload.description_for_source(task)
        expect(description.text).to eq('Updated summary from Wikipedia')
        expect(description.source_label).to be_nil
      end
    end
  end

  describe '#fetched_data_normalized' do
    let(:task) { build(:wikipedia_book_fetch_task, fetched_data: fetched_data) }

    context 'when the page has an extract' do
      let(:fetched_data) do
        {
          'batchcomplete' => true,
          'query' => {
            'pages' => [
              {
                'pageid' => 28_103_851,
                'title' => 'Medea (Seneca)',
                'extract' => 'Medea is a fabula crepidata written by Seneca the Younger.'
              }
            ]
          }
        }
      end

      it 'returns the description' do
        expect(task.fetched_data_normalized).to eq(
          'description' => 'Medea is a fabula crepidata written by Seneca the Younger.'
        )
      end
    end

    context 'when the page is missing' do
      let(:fetched_data) do
        {
          'batchcomplete' => true,
          'query' => {
            'pages' => [
              {
                'ns' => 0,
                'title' => 'Niebo ze stali. Opowieści z meekhańskiego pogranicza',
                'missing' => true
              }
            ]
          }
        }
      end

      it 'returns an empty hash' do
        expect(task.fetched_data_normalized).to eq({})
      end
    end

    context 'when fetched data is blank' do
      let(:fetched_data) { nil }

      it 'returns an empty hash' do
        expect(task.fetched_data_normalized).to eq({})
      end
    end
  end
end
