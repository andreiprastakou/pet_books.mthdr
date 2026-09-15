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

RSpec.describe Admin::Tasks::OpenLibraryBookFetch do
  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:open_library_fetch_task)).to be_valid
    end
  end

  describe '.setup' do
    let!(:external_identity) { create(:external_identity) }

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
    let(:external_identity) { create(:external_identity, external_id: 'OL27448W') }
    let(:fetcher) { instance_double(Admin::InfoFetchers::OpenLibrary::Api::BookDetailsFetcher) }
    let(:api_data) { { 'key' => '/works/OL27448W', 'title' => 'The Lord of the Rings' } }

    before do
      allow(Admin::InfoFetchers::OpenLibrary::Api::BookDetailsFetcher)
        .to receive(:new).with(external_identity.external_id).and_return(fetcher)
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
        expect(task.fetch_error_details).to eq('Failed to fetch Open Library work data')
      end
    end
  end

  describe '#book' do
    let(:book) { create(:book) }
    let(:external_identity) { create(:external_identity, owner: book) }
    let(:task) { create(:open_library_fetch_task, target: external_identity) }

    it 'returns the external identity owner book' do
      expect(task.book).to eq(book)
    end

    context 'when the owner is not a book' do
      let(:external_identity) { create(:external_identity, owner: create(:author)) }

      it 'raises' do
        expect { task.book }.to raise_error(ArgumentError, 'Open Library fetch target must belong to a book')
      end
    end
  end

  describe '#fetched_identifiers' do
    let(:task) { build(:open_library_fetch_task, fetched_data: fetched_data) }
    let(:fetched_data) do
      {
        'identifiers' => {
          'wikidata' => ['Q137179018'],
          'goodreads' => ['87596585'],
          'librarything' => ['33363109'],
          'isfdb' => ['3537436']
        }
      }
    end

    it 'returns allowed identifier pairs and skips unknown resources' do
      expect(task.fetched_identifiers).to eq(
        [
          ['wikidata', 'Q137179018'],
          ['goodreads', '87596585'],
          ['librarything', '33363109']
        ]
      )
    end
  end

  describe '#fetched_description' do
    let(:task) { build(:open_library_fetch_task, fetched_data: fetched_data) }

    context 'when description is a typed text object' do
      let(:fetched_data) { { 'description' => { 'type' => '/type/text', 'value' => 'An epic fantasy novel.' } } }

      it 'returns the value' do
        expect(task.fetched_description).to eq('An epic fantasy novel.')
      end
    end

    context 'when description is a string' do
      let(:fetched_data) { { 'description' => 'Plain description' } }

      it 'returns the string' do
        expect(task.fetched_description).to eq('Plain description')
      end
    end

    context 'when description contains HTML' do
      let(:fetched_data) do
        { 'description' => '<p>A tale of <b>adventure</b> and <i>mystery</i>.</p>' }
      end

      it 'strips tags and returns plain text' do
        expect(task.fetched_description).to eq('A tale of adventure and mystery.')
      end
    end
  end

  describe '#add_identity!' do
    subject(:call) { task.add_identity!('wikidata', 'Q137179018') }

    let(:book) { create(:book) }
    let!(:external_identity) { create(:external_identity, owner: book) }
    let!(:task) { create(:open_library_fetch_task, target: external_identity) }

    it 'creates an external identity on the book' do
      expect { call }.to change(book.external_identities, :count).by(1)
      identity = book.external_identities.find_by!(external_resource: :wikidata)
      expect(identity.external_id).to eq('Q137179018')
      expect(identity.external_link.url).to eq('https://www.wikidata.org/wiki/Q137179018')
    end
  end

  describe '#apply_summary!' do
    subject(:call) { task.apply_summary!('Updated summary from Open Library', 'Open Library') }

    let(:book) { create(:book, summary: 'Old summary') }
    let(:external_identity) { create(:external_identity, owner: book) }
    let(:task) { create(:open_library_fetch_task, target: external_identity) }

    it 'updates the book summary and summary_src' do
      call
      book.reload
      expect(book.summary).to eq('Updated summary from Open Library')
      expect(book.summary_src).to eq('Open Library')
    end
  end

  describe '#fetched_usable_values' do
    let(:task) { build(:open_library_fetch_task, fetched_data: fetched_data) }
    let(:fetched_data) do
      {
        'title' => 'The Lord of the Rings',
        'description' => { 'type' => '/type/text', 'value' => 'An epic fantasy novel.' },
        'authors' => [
          { 'author' => { 'key' => '/authors/OL26320A' } },
          { 'author' => { 'key' => '/authors/OL26321A' } }
        ],
        'genres' => %w[Fantasy Adventure],
        'series' => [
          { 'series' => { 'key' => '/series/OL123S' } }
        ],
        'identifiers' => { 'wikidata' => ['Q15228'] },
        'links' => [
          { 'title' => 'Wikipedia', 'url' => 'https://en.wikipedia.org/wiki/The_Lord_of_the_Rings' },
          { 'title' => 'Missing url' },
          'not-a-hash'
        ],
        'first_sentence' => { 'type' => '/type/text', 'value' => 'When Mr. Bilbo Baggins of Bag End announced...' },
        'subject_people' => ['Frodo Baggins', 'Gandalf', '', nil],
        'covers' => [12_345],
        'subjects' => %w[Fantasy Fiction],
        'first_publish_date' => '1954'
      }
    end

    it 'returns usable fields and mapped related entities' do
      expect(task.fetched_usable_values).to eq(
        {
          'title' => 'The Lord of the Rings',
          'description' => { 'type' => '/type/text', 'value' => 'An epic fantasy novel.' },
          'authors' => [
            { 'external_id' => '/authors/OL26320A' },
            { 'external_id' => '/authors/OL26321A' }
          ],
          'genres' => [
            { 'external_id' => 'Fantasy' },
            { 'external_id' => 'Adventure' }
          ],
          'series' => [
            { 'external_id' => '/series/OL123S' }
          ],
          'identifiers' => { 'wikidata' => ['Q15228'] },
          'links' => ['https://en.wikipedia.org/wiki/The_Lord_of_the_Rings'],
          'first_sentence' => 'When Mr. Bilbo Baggins of Bag End announced...',
          'subject_people' => ['Frodo Baggins', 'Gandalf'],
          'covers' => [12_345]
        }
      )
    end

    context 'when fetched_data is nil' do
      let(:fetched_data) { nil }

      it 'returns an empty hash' do
        expect(task.fetched_usable_values).to eq({})
      end
    end

    context 'when fetched_data is not a hash' do
      let(:fetched_data) { ['not', 'a', 'hash'] }

      it 'returns an empty hash' do
        expect(task.fetched_usable_values).to eq({})
      end
    end

    context 'when related collections are malformed' do
      let(:fetched_data) do
        {
          'title' => 'Broken Work',
          'authors' => 'not-an-array',
          'genres' => { 'Fantasy' => true },
          'series' => [
            'plain-string',
            { 'series' => {} },
            { 'series' => { 'key' => '/series/OL1S' } },
            nil
          ]
        }
      end

      it 'skips invalid entries and keeps valid ones' do
        expect(task.fetched_usable_values).to eq(
          {
            'title' => 'Broken Work',
            'series' => [{ 'external_id' => '/series/OL1S' }]
          }
        )
      end
    end

    context 'when author entries miss keys' do
      let(:fetched_data) do
        {
          'authors' => [
            { 'type' => { 'key' => '/type/author_role' } },
            { 'author' => { 'key' => '' } },
            { 'author' => { 'key' => '/authors/OL1A' } }
          ]
        }
      end

      it 'omits blank author ids' do
        expect(task.fetched_usable_values).to eq(
          {
            'authors' => [{ 'external_id' => '/authors/OL1A' }]
          }
        )
      end
    end

    context 'with a lifelike Open Library work fixture' do
      let(:fetched_data) do
        JSON.parse(
          File.read(
            Rails.root.join(
              'engines/admin/spec/fixtures/open_library/work_fetch_pillars_of_the_earth.json'
            )
          )
        )
      end

      it 'extracts usable values from the real-shaped payload' do
        expect(task.fetched_usable_values).to eq(
          {
            'title' => 'The Pillars of the Earth',
            'description' => fetched_data['description'],
            'authors' => [{ 'external_id' => '/authors/OL229268A' }],
            'genres' => [
              { 'external_id' => '/tags/OL180T' },
              { 'external_id' => '/tags/OL170T' }
            ],
            'links' => [
              'http://viaf.org/viaf/310270194',
              'https://en.wikipedia.org/wiki/The_Pillars_of_the_Earth',
              'https://ken-follett.com/books/the-pillars-of-the-earth/',
              'https://thegreatestbooks.org/items/334'
            ],
            'first_sentence' =>
              'IN A BROAD VALLEY, at the foot of a sloping hillside, beside a clear bubbling stream, Tom was building a house.',
            'subject_people' => fetched_data['subject_people'],
            'covers' => fetched_data['covers']
          }
        )
      end
    end
  end
end
