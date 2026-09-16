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

RSpec.describe Admin::Tasks::WikidataBookFetch do
  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:wikidata_fetch_task)).to be_valid
    end
  end

  describe '.setup' do
    let(:external_identity) do
      create(:external_identity, external_resource: :wikidata, external_id: "Q#{SecureRandom.random_number(1_000_000_000)}")
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
      create(:external_identity, external_resource: :wikidata, external_id: "Q#{SecureRandom.random_number(1_000_000_000)}")
    end
    let(:fetcher) { instance_double(Admin::InfoFetchers::Wikidata::Api::BookDetailsFetcher) }
    let(:api_data) do
      {
        'id' => external_identity.external_id,
        'labels' => { 'en' => 'The Hobbit' },
        'descriptions' => { 'en' => '1937 novel by J. R. R. Tolkien' }
      }
    end

    before do
      allow(Admin::InfoFetchers::Wikidata::Api::BookDetailsFetcher)
        .to receive(:new).with(external_identity.external_id).and_return(fetcher)
      allow(fetcher).to receive(:fetch).and_return(api_data)
      allow(Admin::Wikidata::EntityLookup).to receive(:cache_from_item!)
    end

    it 'stores fetched data on the task' do
      call
      expect(task.reload.status).to eq('fetched')
      expect(task.fetched_data).to eq(api_data)
    end

    it 'caches lookup entities from the payload' do
      call
      expect(Admin::Wikidata::EntityLookup).to have_received(:cache_from_item!)
        .with(api_data, data: kind_of(Hash))
    end

    context 'when the fetch fails' do
      before { allow(fetcher).to receive(:fetch).and_return(nil) }

      it 'marks the task as failed' do
        call
        expect(task.reload.status).to eq('failed')
        expect(task.fetch_error_details).to eq('Failed to fetch Wikidata item data')
        expect(Admin::Wikidata::EntityLookup).not_to have_received(:cache_from_item!)
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
        external_id: "Q#{SecureRandom.random_number(1_000_000_000)}"
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
          external_id: "Q#{SecureRandom.random_number(1_000_000_000)}"
        )
      end

      it 'raises' do
        expect { task.book }.to raise_error(ArgumentError, 'Wikidata fetch target must belong to a book')
      end
    end
  end

  describe '#fetched_data_normalized' do
    let(:task) { build(:wikidata_fetch_task, fetched_data: fetched_data) }
    let(:fetched_data) { { 'statements' => {}, 'sitelinks' => {} } }
    let(:usable) { { 'authors' => ['Q1'] } }
    let(:enriched) { { 'authors' => [{ 'id' => 'Q1', 'label' => 'Author' }] } }

    before do
      allow(Admin::Wikidata::BookUsableValues).to receive(:call).with(fetched_data).and_return(usable)
      allow(Admin::Wikidata::EntityLookup).to receive(:enrich)
        .with(usable, fetch_missing: true).and_return(enriched)
    end

    it 'enriches usable values via EntityLookup' do
      expect(task.fetched_data_normalized).to eq(enriched)
      expect(Admin::Wikidata::EntityLookup).to have_received(:enrich).with(usable, fetch_missing: true)
    end
  end
end
