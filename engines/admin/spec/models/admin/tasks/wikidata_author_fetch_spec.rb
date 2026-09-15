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

RSpec.describe Admin::Tasks::WikidataAuthorFetch do
  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:wikidata_author_fetch_task)).to be_valid
    end
  end

  describe '.setup' do
    let!(:external_identity) do
      create(
        :external_identity,
        owner: create(:author),
        external_resource: :wikidata,
        external_id: 'Q892'
      )
    end

    it 'creates a new wikidata author fetch task' do
      expect { described_class.setup(external_identity) }.to change(described_class, :count).by(1)
      new_record = described_class.last
      expect(new_record.target).to eq(external_identity)
      expect(new_record.status).to eq('requested')
      expect(new_record.chat).to be_nil
    end
  end

  describe '#perform' do
    subject(:call) { task.perform }

    let(:author) { create(:author) }
    let(:external_identity) do
      create(:external_identity, owner: author, external_resource: :wikidata, external_id: 'Q892')
    end
    let(:task) { create(:wikidata_author_fetch_task, target: external_identity) }
    let(:fetcher) { instance_double(Admin::InfoFetchers::Wikidata::Api::AuthorDetailsFetcher) }
    let(:api_data) do
      {
        'id' => 'Q892',
        'labels' => { 'en' => 'J. R. R. Tolkien' },
        'descriptions' => { 'en' => 'English writer and philologist' }
      }
    end

    before do
      allow(Admin::InfoFetchers::Wikidata::Api::AuthorDetailsFetcher)
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
        .with(api_data, usable_values: kind_of(Hash))
    end

    context 'when the fetch fails' do
      before { allow(fetcher).to receive(:fetch).and_return(nil) }

      it 'marks the task as failed' do
        call
        expect(task.reload.status).to eq('failed')
        expect(task.fetch_error_details).to eq('Failed to fetch Wikidata author data')
        expect(Admin::Wikidata::EntityLookup).not_to have_received(:cache_from_item!)
      end
    end
  end

  describe '#author' do
    let(:author) { create(:author) }
    let(:external_identity) do
      create(:external_identity, owner: author, external_resource: :wikidata, external_id: 'Q892')
    end
    let(:task) { create(:wikidata_author_fetch_task, target: external_identity) }

    it 'returns the external identity owner author' do
      expect(task.author).to eq(author)
    end

    context 'when the owner is not an author' do
      let(:external_identity) do
        create(:external_identity, owner: create(:book), external_resource: :wikidata, external_id: 'Q1')
      end

      it 'raises' do
        expect { task.author }.to raise_error(
          ArgumentError,
          'Wikidata author fetch target must belong to an author'
        )
      end
    end
  end

  describe '#fetched_usable_values' do
    let(:task) { build(:wikidata_author_fetch_task, fetched_data: fetched_data) }
    let(:fetched_data) { { 'statements' => {}, 'sitelinks' => {} } }
    let(:usable) { { 'countries' => ['Q30'] } }
    let(:enriched) { { 'countries' => [{ 'id' => 'Q30', 'label' => 'United States' }] } }

    before do
      allow(Admin::Wikidata::AuthorUsableValues).to receive(:call).with(fetched_data).and_return(usable)
      allow(Admin::Wikidata::EntityLookup).to receive(:enrich)
        .with(usable, fetch_missing: true).and_return(enriched)
    end

    it 'enriches usable values via EntityLookup' do
      expect(task.fetched_usable_values).to eq(enriched)
      expect(Admin::Wikidata::EntityLookup).to have_received(:enrich).with(usable, fetch_missing: true)
    end
  end

  describe '#fetched_label' do
    let(:task) { build(:wikidata_author_fetch_task, fetched_data: { 'labels' => { 'en' => 'J. R. R. Tolkien' } }) }

    it 'returns the English label' do
      expect(task.fetched_label).to eq('J. R. R. Tolkien')
    end
  end

  describe '#fetched_description' do
    let(:task) do
      build(:wikidata_author_fetch_task, fetched_data: { 'descriptions' => { 'en' => 'English writer' } })
    end

    it 'returns the English description' do
      expect(task.fetched_description).to eq('English writer')
    end
  end
end
