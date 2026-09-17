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

  describe '#apply_year!' do
    subject(:call) { task.apply_year!(2025) }

    let(:book) { create(:book, year_published: 1900) }
    let(:external_identity) do
      create(:external_identity, owner: book, external_resource: :wikidata, external_id: 'Q1')
    end
    let(:task) { create(:wikidata_fetch_task, target: external_identity, status: :fetched) }

    it 'updates the book year' do
      call
      expect(book.reload.year_published).to eq(2025)
    end
  end

  describe '#apply_literary_form!' do
    subject(:call) { task.apply_literary_form!('novella') }

    let(:book) { create(:book, literary_form: 'novel') }
    let(:external_identity) do
      create(:external_identity, owner: book, external_resource: :wikidata, external_id: 'Q1')
    end
    let(:task) { create(:wikidata_fetch_task, target: external_identity, status: :fetched) }

    it 'updates the book literary form' do
      call
      expect(book.reload.literary_form).to eq('novella')
    end
  end

  describe '#add_identity!' do
    subject(:call) { task.add_identity!('open_library', 'OL42413123W') }

    let(:book) { create(:book) }
    let(:external_identity) do
      create(:external_identity, owner: book, external_resource: :wikidata, external_id: 'Q1')
    end
    let(:task) { create(:wikidata_fetch_task, target: external_identity, status: :fetched) }

    it 'creates an external identity on the book' do
      expect { call }.to change { book.external_identities.open_library.count }.by(1)
      identity = book.external_identities.find_by!(external_resource: :open_library)
      expect(identity.external_id).to eq('OL42413123W')
    end
  end

  describe '#add_author_identity!' do
    subject(:call) { task.add_author_identity!('Q457608', author: author) }

    let(:author) { create(:author) }
    let(:book) { create(:book, authors: [author]) }
    let(:external_identity) do
      create(:external_identity, owner: book, external_resource: :wikidata, external_id: 'Q1')
    end
    let(:task) { create(:wikidata_fetch_task, target: external_identity, status: :fetched) }

    it 'creates a wikidata identity on the author' do
      expect { call }.to change(author.external_identities, :count).by(1)
      identity = author.external_identities.find_by!(external_resource: :wikidata)
      expect(identity.external_id).to eq('Q457608')
    end
  end

  describe '#add_genre_identity!' do
    subject(:call) { task.add_genre_identity!('Q132311', genre: genre) }

    let(:book) { create(:book) }
    let(:genre) { create(:genre) }
    let(:external_identity) do
      create(:external_identity, owner: book, external_resource: :wikidata, external_id: 'Q1')
    end
    let(:task) { create(:wikidata_fetch_task, target: external_identity, status: :fetched) }

    it 'creates a wikidata identity on the genre and links it to the book' do
      expect { call }.to change(genre.external_identities, :count).by(1)
        .and change { book.genres.count }.by(1)
      expect(genre.external_identities.find_by!(external_resource: :wikidata).external_id).to eq('Q132311')
      expect(book.genres.find_by!(genre_id: genre.id)).to be_present
    end

    context 'when the identity already exists but the genre is not on the book' do
      before do
        create(:external_identity, owner: genre, external_resource: :wikidata, external_id: 'Q132311')
      end

      it 'links the genre to the book without creating another identity' do
        expect { call }.to change { book.genres.count }.by(1)
        expect(genre.external_identities.count).to eq(1)
      end
    end
  end

  describe '#add_series_identity!' do
    subject(:call) { task.add_series_identity!('Q123', series: series) }

    let(:book) { create(:book) }
    let(:series) { create(:series) }
    let(:external_identity) do
      create(:external_identity, owner: book, external_resource: :wikidata, external_id: 'Q1')
    end
    let(:task) { create(:wikidata_fetch_task, target: external_identity, status: :fetched) }

    it 'creates a wikidata identity on the series and links it to the book' do
      expect { call }.to change(series.external_identities, :count).by(1)
        .and change { book.book_series.count }.by(1)
      expect(series.external_identities.find_by!(external_resource: :wikidata).external_id).to eq('Q123')
      expect(book.series_ids).to include(series.id)
    end

    context 'when the identity already exists but the series is not on the book' do
      before do
        create(:external_identity, owner: series, external_resource: :wikidata, external_id: 'Q123')
      end

      it 'links the series to the book without creating another identity' do
        expect { call }.to change { book.book_series.count }.by(1)
        expect(series.external_identities.count).to eq(1)
      end
    end
  end

  describe '#add_link!' do
    subject(:call) do
      task.add_link!('https://en.wikipedia.org/wiki/The_Hobbit', external_resource: 'wikipedia')
    end

    let(:book) { create(:book) }
    let(:external_identity) do
      create(:external_identity, owner: book, external_resource: :wikidata, external_id: 'Q1')
    end
    let(:task) { create(:wikidata_fetch_task, target: external_identity, status: :fetched) }

    it 'creates an external link on the book' do
      expect { call }.to change(book.external_links, :count).by(1)
      link = book.external_links.find_by!(url: 'https://en.wikipedia.org/wiki/The_Hobbit')
      expect(link.external_resource).to eq('wikipedia')
    end
  end

  describe '#wikipedia_sitelinks / #other_sitelinks' do
    let(:task) { build(:wikidata_fetch_task, fetched_data: {}) }
    let(:normalized) do
      {
        'sitelinks' => [
          {
            'title' => 'The Hobbit',
            'language' => 'en',
            'url' => 'https://en.wikipedia.org/wiki/The_Hobbit'
          },
          {
            'title' => 'Robert Jordan',
            'language' => 'enwikiquote',
            'url' => 'https://en.wikiquote.org/wiki/Robert_Jordan'
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
            'url' => 'https://en.wikiquote.org/wiki/Robert_Jordan'
          }
        ]
      )
    end
  end
end
