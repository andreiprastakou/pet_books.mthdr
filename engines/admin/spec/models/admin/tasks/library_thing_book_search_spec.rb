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

RSpec.describe Admin::Tasks::LibraryThingBookSearch do
  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:library_thing_search_task)).to be_valid
    end
  end

  describe '.setup' do
    let(:book) { create(:book) }

    it 'creates a new library thing search task' do
      expect { described_class.setup(book) }.to change(described_class, :count).by(1)
      new_record = described_class.last
      expect(new_record.target).to eq(book)
      expect(new_record.status).to eq('requested')
      expect(new_record.chat).to be_nil
    end
  end

  describe '#perform' do
    subject(:call) { task.perform }

    let(:task) { create(:library_thing_search_task, target: book) }
    let(:book) { create(:book, title: 'The Hobbit') }
    let(:fetcher) { instance_double(Admin::InfoFetchers::LibraryThing::Api::WorkByTitleFetcher) }
    let(:result) do
      {
        'idlist' => {
          'title' => 'The Hobbit',
          'link' => 'https://www.librarything.com/work/14184045',
          'isbn' => %w[0261102664 0345445600]
        }
      }
    end

    before do
      allow(Admin::InfoFetchers::LibraryThing::Api::WorkByTitleFetcher)
        .to receive(:new).with(book.title).and_return(fetcher)
      allow(fetcher).to receive(:fetch).and_return(result)
    end

    it 'stores search results on the task' do
      expect(call).to eq(result)
      expect(task.reload.status).to eq('fetched')
      expect(task.fetched_data).to eq(result)
      expect(task.chat).to be_nil
    end
  end

  describe '#fetched_data_normalized' do
    let(:task) { build(:library_thing_search_task, fetched_data: fetched_data) }
    let(:fetched_data) do
      JSON.parse(
        Rails.root.join(
          'engines/admin/spec/fixtures/library_thing/book_search_by_title.json'
        ).read
      )
    end

    it 'returns the LibraryThing work link' do
      expect(task.fetched_data_normalized).to eq(
        'external_link' => 'https://www.librarything.com/work/31661953'
      )
    end

    context 'when fetched data is blank' do
      let(:fetched_data) { nil }

      it 'returns an empty hash' do
        expect(task.fetched_data_normalized).to eq({})
      end
    end

    context 'when the response has no link' do
      let(:fetched_data) { { 'idlist' => { 'title' => 'Unknown' } } }

      it 'returns an empty hash' do
        expect(task.fetched_data_normalized).to eq({})
      end
    end
  end

  describe '#add_work_link!' do
    subject(:call) { task.add_work_link!(url) }

    let(:task) { create(:library_thing_search_task, target: book, status: :fetched) }
    let(:book) { create(:book) }
    let(:url) { 'https://www.librarything.com/work/31661953' }

    it 'creates an external link without changing task status' do
      expect { call }.to change(book.external_links, :count).by(1)
      link = call
      expect(link.external_resource).to eq(ExternalResources::LIBRARYTHING)
      expect(link.url).to eq('https://www.librarything.com/work/31661953')
      expect(task.reload.status).to eq('fetched')
    end

    context 'when url is invalid' do
      let(:url) { 'not-a-librarything-url' }

      it 'raises and does not change status' do
        expect { call }.to raise_error(ArgumentError, 'Invalid LibraryThing work url')
        expect(task.reload.status).to eq('fetched')
      end
    end
  end

  describe '#add_work_identity!' do
    subject(:call) { task.add_work_identity!(work_id) }

    let(:task) { create(:library_thing_search_task, target: book, status: :fetched) }
    let(:book) { create(:book) }
    let(:work_id) { '14184045' }

    it 'creates an external identity without changing task status' do
      expect { call }.to change(book.external_identities, :count).by(1)
      identity = call
      expect(identity).to have_attributes(
        external_resource: 'librarything',
        external_id: '14184045'
      )
      expect(identity.external_link.url).to eq('https://www.librarything.com/work/14184045')
      expect(task.reload.status).to eq('fetched')
    end

    context 'when work id is invalid' do
      let(:work_id) { 'not-a-work-id' }

      it 'raises and does not change status' do
        expect { call }.to raise_error(ArgumentError, 'Invalid LibraryThing work id')
        expect(task.reload.status).to eq('fetched')
      end
    end
  end

  describe '.next_unresolved' do
    let!(:first_task) { create(:library_thing_search_task, status: :fetched) }
    let!(:second_task) { create(:library_thing_search_task, status: :fetched) }

    before { create(:library_thing_search_task, status: :verified) }

    it 'returns the earliest fetched task' do
      expect(described_class.next_unresolved).to eq(first_task)
    end

    it 'can exclude a task' do
      expect(described_class.next_unresolved(excluding: first_task)).to eq(second_task)
    end
  end
end
