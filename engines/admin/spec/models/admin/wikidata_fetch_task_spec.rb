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

RSpec.describe Admin::WikidataFetchTask do
  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:wikidata_fetch_task)).to be_valid
    end
  end

  describe '.setup' do
    let(:external_identity) do
      create(:external_identity, external_resource: :wikidata, identificator: "Q#{SecureRandom.random_number(1_000_000_000)}")
    end

    it 'creates a new wikidata fetch task' do
      expect { described_class.setup(external_identity) }.to change(described_class, :count).by(1)
      new_record = described_class.last
      expect(new_record.target).to eq(external_identity)
      expect(new_record.status).to eq('requested')
      expect(new_record.chat).to be_nil
    end
  end

  describe '#perform' do
    subject(:call) { task.perform }

    let(:task) { create(:wikidata_fetch_task, target: external_identity) }
    let(:external_identity) do
      create(:external_identity, external_resource: :wikidata, identificator: "Q#{SecureRandom.random_number(1_000_000_000)}")
    end
    let(:fetcher) { instance_double(InfoFetchers::Wikidata::Api::BookDetailsFetcher) }
    let(:api_data) do
      {
        'id' => external_identity.identificator,
        'labels' => { 'en' => 'The Hobbit' },
        'descriptions' => { 'en' => '1937 novel by J. R. R. Tolkien' }
      }
    end

    before do
      allow(InfoFetchers::Wikidata::Api::BookDetailsFetcher)
        .to receive(:new).with(external_identity.identificator).and_return(fetcher)
      allow(fetcher).to receive(:fetch).and_return(api_data)
    end

    it 'stores fetched data on the task' do
      call
      expect(task.reload.status).to eq('fetched')
      expect(task.fetched_data).to eq(api_data)
    end

    context 'when the fetch fails' do
      before { allow(fetcher).to receive(:fetch).and_return(nil) }

      it 'marks the task as failed' do
        call
        expect(task.reload.status).to eq('failed')
        expect(task.fetch_error_details).to eq('Failed to fetch Wikidata item data')
      end
    end
  end

  describe '#book' do
    let(:book) { create(:book) }
    let(:external_identity) do
      create(
        :external_identity,
        owner: book,
        external_resource: :wikidata,
        identificator: "Q#{SecureRandom.random_number(1_000_000_000)}"
      )
    end
    let(:task) { create(:wikidata_fetch_task, target: external_identity) }

    it 'returns the external identity owner book' do
      expect(task.book).to eq(book)
    end

    context 'when the owner is not a book' do
      let(:external_identity) do
        create(
          :external_identity,
          owner: create(:author),
          external_resource: :wikidata,
          identificator: "Q#{SecureRandom.random_number(1_000_000_000)}"
        )
      end

      it 'raises' do
        expect { task.book }.to raise_error(ArgumentError, 'Wikidata fetch target must belong to a book')
      end
    end
  end

  describe '#fetched_description' do
    let(:task) { build(:wikidata_fetch_task, fetched_data: fetched_data) }

    context 'when descriptions are plain strings' do
      let(:fetched_data) { { 'descriptions' => { 'en' => 'A fantasy novel' } } }

      it 'returns the English description' do
        expect(task.fetched_description).to eq('A fantasy novel')
      end
    end

    context 'when descriptions are language objects' do
      let(:fetched_data) do
        { 'descriptions' => { 'en' => { 'language' => 'en', 'value' => 'A fantasy novel' } } }
      end

      it 'returns the value' do
        expect(task.fetched_description).to eq('A fantasy novel')
      end
    end
  end

  describe '#fetched_label' do
    let(:task) { build(:wikidata_fetch_task, fetched_data: { 'labels' => { 'en' => 'The Hobbit' } }) }

    it 'returns the English label' do
      expect(task.fetched_label).to eq('The Hobbit')
    end
  end
end
