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
        .with(api_data, data: kind_of(Hash))
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

  describe '#fetched_data_normalized' do
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
      expect(task.fetched_data_normalized).to eq(enriched)
      expect(Admin::Wikidata::EntityLookup).to have_received(:enrich).with(usable, fetch_missing: true)
    end
  end

  describe '#apply_birth_year!' do
    subject(:call) { task.apply_birth_year! }

    let(:author) { create(:author, birth_year: nil) }
    let(:external_identity) do
      create(:external_identity, owner: author, external_resource: :wikidata, external_id: 'Q892')
    end
    let(:task) do
      create(
        :wikidata_author_fetch_task,
        target: external_identity,
        status: :fetched,
        fetched_data: {
          'statements' => {
            'P569' => [
              {
                'rank' => 'normal',
                'value' => {
                  'type' => 'value',
                  'content' => { 'time' => '+1892-01-03T00:00:00Z', 'precision' => 11 }
                }
              }
            ]
          }
        }
      )
    end

    it 'sets the author birth year from the fetched date' do
      expect { call }.to change { author.reload.birth_year }.from(nil).to(1892)
      expect(task.reload.status).to eq('fetched')
    end
  end

  describe '#apply_death_year!' do
    subject(:call) { task.apply_death_year!(1973) }

    let(:author) { create(:author, death_year: 1970) }
    let(:external_identity) do
      create(:external_identity, owner: author, external_resource: :wikidata, external_id: 'Q892')
    end
    let(:task) { create(:wikidata_author_fetch_task, target: external_identity, status: :fetched) }

    it 'updates the author death year' do
      expect { call }.to change { author.reload.death_year }.from(1970).to(1973)
    end
  end

  describe '#add_identity!' do
    subject(:call) { task.add_identity!('open_library', 'OL26320A') }

    let(:author) { create(:author) }
    let(:external_identity) do
      create(:external_identity, owner: author, external_resource: :wikidata, external_id: 'Q892')
    end
    let(:task) { create(:wikidata_author_fetch_task, target: external_identity, status: :fetched) }

    it 'creates an external identity on the author' do
      expect { call }.to change { author.external_identities.open_library.count }.by(1)
      identity = author.external_identities.find_by!(external_resource: :open_library)
      expect(identity.external_id).to eq('OL26320A')
    end
  end

  describe '#add_link!' do
    subject(:call) do
      task.add_link!('https://en.wikipedia.org/wiki/J._R._R._Tolkien', external_resource: 'wikipedia')
    end

    let(:author) { create(:author) }
    let(:external_identity) do
      create(:external_identity, owner: author, external_resource: :wikidata, external_id: 'Q892')
    end
    let(:task) { create(:wikidata_author_fetch_task, target: external_identity, status: :fetched) }

    it 'creates an external link on the author' do
      expect { call }.to change(author.external_links, :count).by(1)
      link = author.external_links.find_by!(url: 'https://en.wikipedia.org/wiki/J._R._R._Tolkien')
      expect(link.external_resource).to eq('wikipedia')
    end
  end

  describe '#wikipedia_sitelinks / #other_sitelinks' do
    let(:task) { build(:wikidata_author_fetch_task, fetched_data: {}) }
    let(:normalized) do
      {
        'sitelinks' => [
          {
            'title' => 'J. R. R. Tolkien',
            'language' => 'en',
            'url' => 'https://en.wikipedia.org/wiki/J._R._R._Tolkien'
          },
          {
            'title' => 'J. R. R. Tolkien',
            'language' => 'enwikiquote',
            'url' => 'https://en.wikiquote.org/wiki/J._R._R._Tolkien'
          }
        ]
      }
    end

    before { allow(task).to receive(:fetched_data_normalized).and_return(normalized) }

    it 'splits wikipedia and other sitelinks' do
      expect(task.wikipedia_sitelinks).to eq([normalized['sitelinks'].first])
      expect(task.other_sitelinks).to eq(
        [
          {
            'external_resource' => 'en.wikiquote.org',
            'url' => 'https://en.wikiquote.org/wiki/J._R._R._Tolkien'
          }
        ]
      )
    end
  end

  describe '.parse_year' do
    it 'extracts a four-digit year from a date string' do
      expect(described_class.parse_year('1892-01-03')).to eq(1892)
      expect(described_class.parse_year('1973')).to eq(1973)
      expect(described_class.parse_year(nil)).to be_nil
    end
  end
end
