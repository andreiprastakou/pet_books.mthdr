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

RSpec.describe Admin::Tasks::WikidataAuthorWorksFetch do
  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:wikidata_author_works_fetch_task)).to be_valid
    end
  end

  describe '.setup' do
    let(:author) { create(:author) }
    let!(:external_identity) do
      create(
        :external_identity,
        owner: author,
        external_resource: :wikidata,
        external_id: 'Q23434'
      )
    end

    it 'creates a task targeting the author with the entity id in input_data', :aggregate_failures do
      expect { described_class.setup(external_identity) }.to change(described_class, :count).by(1)
      new_record = described_class.last
      expect(new_record.target).to eq(author)
      expect(new_record.status).to eq('requested')
      expect(new_record.input_data).to eq('entity_id' => 'Q23434')
      expect(new_record.chat).to be_nil
    end

    context 'when the identity does not belong to an author' do
      let(:external_identity) do
        create(
          :external_identity,
          owner: create(:book),
          external_resource: :wikidata,
          external_id: 'Q1'
        )
      end

      it 'raises an error' do
        expect { described_class.setup(external_identity) }
          .to raise_error(ArgumentError, 'Wikidata author works fetch target must belong to an author')
      end
    end
  end

  describe '#perform' do
    subject(:call) { task.perform }

    let(:author) { create(:author) }
    let(:task) do
      create(:wikidata_author_works_fetch_task, target: author, input_data: { 'entity_id' => 'Q23434' })
    end
    let(:fetcher) { instance_double(Admin::InfoFetchers::Wikidata::Api::AuthorWorksFetcher) }
    let(:works_data) do
      [
        {
          'work' => 'Q43361',
          'work_label' => 'The Books of Blood',
          'publication_date' => '1984-01-01T00:00:00Z',
          'type_label' => 'book series',
          'language_label' => 'English'
        }
      ]
    end

    before do
      allow(Admin::InfoFetchers::Wikidata::Api::AuthorWorksFetcher)
        .to receive(:new).with('Q23434').and_return(fetcher)
      allow(fetcher).to receive(:fetch).and_return(works_data)
    end

    it 'stores fetched works on the task' do
      call
      expect(task.reload.status).to eq('fetched')
      expect(task.fetched_data).to eq(works_data)
    end

    context 'when the fetch fails' do
      before { allow(fetcher).to receive(:fetch).and_return(nil) }

      it 'marks the task as failed' do
        call
        expect(task.reload.status).to eq('failed')
        expect(task.fetch_error_details).to eq('Failed to fetch Wikidata author works')
      end
    end

    context 'when there is no entity id' do
      let(:task) { create(:wikidata_author_works_fetch_task, target: author, input_data: {}) }

      it 'marks the task as failed' do
        call
        expect(task.reload.status).to eq('failed')
        expect(task.fetch_error_details).to eq('Author has no Wikidata identity')
        expect(Admin::InfoFetchers::Wikidata::Api::AuthorWorksFetcher).not_to have_received(:new)
      end
    end

    context 'when the result is empty' do
      before { allow(fetcher).to receive(:fetch).and_return([]) }

      it 'marks the task as rejected' do
        call
        expect(task.reload.status).to eq('rejected')
        expect(task.fetched_data).to eq([])
      end
    end
  end

  describe '.parse_year' do
    it 'extracts a four-digit year' do
      expect(described_class.parse_year('1955-01-01T00:00:00Z')).to eq(1955)
      expect(described_class.parse_year('1973')).to eq(1973)
      expect(described_class.parse_year(nil)).to be_nil
    end
  end

  describe '#apply_work!' do
    let(:author) { create(:author) }
    let(:task) { create(:wikidata_author_works_fetch_task, target: author) }

    it 'creates a book with wikidata identity', :aggregate_failures do
      book = task.apply_work!(title: 'New Work', year: '1960', entity_id: 'Q200')
      expect(book).to be_persisted
      expect(book.title).to eq('New Work')
      expect(book.year_published).to eq(1960)
      expect(book.authors).to contain_exactly(author)
      expect(book.external_identities.wikidata.find_by!(external_id: 'Q200')).to be_present
    end

    it 'updates an existing author book and skips duplicate identity' do
      book = create(:book, authors: [author], title: 'Old', year_published: 1950)
      create(:external_identity, owner: book, external_resource: :wikidata, external_id: 'Q100')

      expect do
        task.apply_work!(title: 'Updated', year: '1955', book_id: book.id, entity_id: 'Q100')
      end.not_to change(Admin::ExternalIdentity, :count)

      expect(book.reload.title).to eq('Updated')
      expect(book.year_published).to eq(1955)
    end

    it 'raises when title is blank' do
      expect { task.apply_work!(title: ' ', year: '1960') }
        .to raise_error(ArgumentError, 'Title is required')
    end
  end
end
