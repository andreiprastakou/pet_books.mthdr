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

RSpec.describe Admin::Tasks::OpenLibraryAuthorFetch do
  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:open_library_author_fetch_task)).to be_valid
    end
  end

  describe '.setup' do
    let!(:external_identity) { create(:external_identity, owner: create(:author), external_id: 'OL1394865A') }

    it 'creates a new open library author fetch task' do
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
      create(:external_identity, owner: author, external_id: 'OL1394865A')
    end
    let(:task) { create(:open_library_author_fetch_task, target: external_identity) }
    let(:fetcher) { instance_double(Admin::InfoFetchers::OpenLibrary::Api::AuthorDetailsFetcher) }
    let(:api_data) { { 'key' => '/authors/OL1394865A', 'name' => 'J. R. R. Tolkien' } }

    before do
      allow(Admin::InfoFetchers::OpenLibrary::Api::AuthorDetailsFetcher)
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
        expect(task.fetch_error_details).to eq('Failed to fetch Open Library author data')
      end
    end
  end

  describe '#author' do
    let(:author) { create(:author) }
    let(:external_identity) { create(:external_identity, owner: author, external_id: 'OL1394865A') }
    let(:task) { create(:open_library_author_fetch_task, target: external_identity) }

    it 'returns the external identity owner author' do
      expect(task.author).to eq(author)
    end

    context 'when the owner is not an author' do
      let(:external_identity) { create(:external_identity, owner: create(:book)) }

      it 'raises' do
        expect { task.author }.to raise_error(
          ArgumentError,
          'Open Library author fetch target must belong to an author'
        )
      end
    end
  end

  describe '#fetched_data_normalized' do
    let(:task) { build(:open_library_author_fetch_task, fetched_data: fetched_data) }
    let(:fetched_data) do
      {
        'name' => 'J. R. R. Tolkien',
        'personal_name' => 'John Ronald Reuel Tolkien',
        'birth_date' => '3 January 1892',
        'death_date' => '2 September 1973',
        'bio' => { 'type' => '/type/text', 'value' => 'English writer and philologist.' },
        'remote_ids' => {
          'viaf' => '95218067',
          'wikidata' => 'Q892',
          'goodreads' => ''
        },
        'links' => [
          { 'title' => 'Wikipedia', 'url' => 'https://en.wikipedia.org/wiki/J._R._R._Tolkien' },
          { 'title' => 'Missing url' },
          'not-a-hash'
        ],
        'photos' => [6_425_004, 'not-an-int', nil],
        'revision' => 12,
        'key' => '/authors/OL26320A',
        'alternate_names' => ['JRR Tolkien']
      }
    end

    it 'returns usable fields with mapped remote ids and links' do
      expect(task.fetched_data_normalized).to eq(
        {
          'name' => 'J. R. R. Tolkien',
          'personal_name' => 'John Ronald Reuel Tolkien',
          'birth_date' => '3 January 1892',
          'death_date' => '2 September 1973',
          'bio' => 'English writer and philologist.',
          'remote_ids' => [
            { 'external_resource' => 'viaf', 'external_id' => '95218067' },
            { 'external_resource' => 'wikidata', 'external_id' => 'Q892' }
          ],
          'links' => [
            { 'label' => 'Wikipedia', 'url' => 'https://en.wikipedia.org/wiki/J._R._R._Tolkien' }
          ],
          'photos' => [6_425_004],
          'revision' => 12
        }
      )
    end

    context 'when fetched_data is nil' do
      let(:fetched_data) { nil }

      it 'returns an empty hash' do
        expect(task.fetched_data_normalized).to eq({})
      end
    end

    context 'when fetched_data is not a hash' do
      let(:fetched_data) { %w[not a hash] }

      it 'returns an empty hash' do
        expect(task.fetched_data_normalized).to eq({})
      end
    end

    context 'when nested collections are malformed' do
      let(:fetched_data) do
        {
          'name' => 'Broken Author',
          'remote_ids' => ['not-a-hash'],
          'links' => { 'url' => 'https://example.com' },
          'photos' => '6425004'
        }
      end

      it 'treats invalid collections as empty and drops them' do
        expect(task.fetched_data_normalized).to eq(
          {
            'name' => 'Broken Author'
          }
        )
      end
    end

    context 'with a lifelike Open Library author fetch fixture' do
      let(:fetched_data) do
        JSON.parse(
          Rails.root.join(
            'engines/admin/spec/fixtures/open_library/author_fetch_dean_koontz.json'
          ).read
        )
      end

      it 'extracts usable values from the real-shaped payload' do
        expect(task.fetched_data_normalized).to eq(
          {
            'name' => 'Dean Koontz',
            'personal_name' => 'Dean R. Koontz',
            'birth_date' => '9 July 1945',
            'bio' => fetched_data['bio'],
            'remote_ids' => [
              { 'external_resource' => 'viaf', 'external_id' => '110880758' },
              { 'external_resource' => 'goodreads', 'external_id' => '9355' },
              { 'external_resource' => 'isni', 'external_id' => '0000000120327893' },
              { 'external_resource' => 'amazon', 'external_id' => 'B000APG4T6' },
              { 'external_resource' => 'librarything', 'external_id' => 'koontzdean' },
              { 'external_resource' => 'wikidata', 'external_id' => 'Q272076' }
            ],
            'links' => [
              { 'label' => 'Official Web Site', 'url' => 'http://www.deankoontz.com/' },
              { 'label' => 'Dean Koontz Books in Order', 'url' => 'https://www.littlestack.com/author/dean-koontz' }
            ],
            'photos' => [6_425_004],
            'revision' => 37
          }
        )
      end
    end
  end

  describe '.parse_year' do
    it 'extracts a four-digit year from a date string' do
      expect(described_class.parse_year('9 July 1945')).to eq(1945)
      expect(described_class.parse_year('2 September 1973')).to eq(1973)
      expect(described_class.parse_year(nil)).to be_nil
    end
  end

  describe '.external_resource_from_label' do
    it 'uses the label, stripping Author boilerplate' do
      expect(described_class.external_resource_from_label('Official Web Site'))
        .to eq('Official Web Site')
      expect(described_class.external_resource_from_label("Author's Wikipedia"))
        .to eq('Wikipedia')
      expect(described_class.external_resource_from_label('Wikipedia Author Entry'))
        .to eq('Wikipedia')
      expect(described_class.external_resource_from_label("Author's Wikipedia Author Entry"))
        .to eq('Wikipedia')
      expect(described_class.external_resource_from_label(nil)).to be_nil
    end
  end

  describe '.filter_bio_reference_links' do
    it 'replaces [label][id] markdown references with the label' do
      expect(described_class.filter_bio_reference_links('See <sup>[1][1]</sup> here'))
        .to eq('See <sup>1</sup> here')
      expect(described_class.filter_bio_reference_links('Read [Dean Koontz][wiki] now'))
        .to eq('Read Dean Koontz now')
      expect(described_class.filter_bio_reference_links(nil)).to be_nil
    end
  end

  describe '#description_for_textarea' do
    let(:task) { build(:open_library_author_fetch_task, fetched_data: fetched_data) }
    let(:fetched_data) do
      { 'bio' => 'Pen names.<sup>[1][1]</sup>' }
    end

    it 'returns the bio with reference links flattened' do
      expect(task.description_for_textarea).to eq('Pen names.<sup>1</sup>')
    end
  end

  describe '#applyable_links' do
    let(:task) { build(:open_library_author_fetch_task, fetched_data: fetched_data) }
    let(:fetched_data) do
      {
        'links' => [
          { 'title' => "Author's Wikipedia Author Entry", 'url' => 'https://en.wikipedia.org/wiki/X' },
          { 'title' => 'Official Web Site', 'url' => 'http://www.example.com/' },
          { 'title' => 'No url' }
        ]
      }
    end

    it 'maps cleaned labels to external_resource' do
      expect(task.applyable_links).to eq(
        [
          { 'external_resource' => 'Wikipedia', 'url' => 'https://en.wikipedia.org/wiki/X' },
          { 'external_resource' => 'Official Web Site', 'url' => 'http://www.example.com/' }
        ]
      )
    end
  end

  describe '#applyable_remote_ids' do
    let(:task) { build(:open_library_author_fetch_task, fetched_data: fetched_data) }
    let(:fetched_data) do
      {
        'remote_ids' => {
          'viaf' => '95218067',
          'wikidata' => 'Q892',
          'goodreads' => '9355',
          'librarything' => 'koontzdean'
        }
      }
    end

    it 'keeps only ExternalIdentity-supported resources' do
      expect(task.applyable_remote_ids).to eq(
        [
          { 'external_resource' => 'wikidata', 'external_id' => 'Q892' },
          { 'external_resource' => 'goodreads', 'external_id' => '9355' },
          { 'external_resource' => 'librarything', 'external_id' => 'koontzdean' }
        ]
      )
    end
  end

  describe '#apply_birth_year!' do
    subject(:call) { task.apply_birth_year! }

    let(:author) { create(:author, birth_year: nil) }
    let(:external_identity) { create(:external_identity, owner: author, external_id: 'OL26320A') }
    let(:task) do
      create(
        :open_library_author_fetch_task,
        target: external_identity,
        status: :fetched,
        fetched_data: { 'birth_date' => '3 January 1892' }
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
    let(:external_identity) { create(:external_identity, owner: author, external_id: 'OL26320A') }
    let(:task) do
      create(
        :open_library_author_fetch_task,
        target: external_identity,
        status: :fetched,
        fetched_data: { 'death_date' => '2 September 1973' }
      )
    end

    it 'updates the author death year' do
      expect { call }.to change { author.reload.death_year }.from(1970).to(1973)
    end
  end

  describe '#apply_description!' do
    subject(:call) { task.apply_description!('English writer and philologist.') }

    let(:author) { create(:author) }
    let(:external_identity) { create(:external_identity, owner: author, external_id: 'OL26320A') }
    let(:task) { create(:open_library_author_fetch_task, target: external_identity, status: :fetched) }

    it 'saves a description sourced from the task' do
      expect { call }.to change(author.descriptions, :count).by(1)
      description = call
      expect(description.text).to eq('English writer and philologist.')
      expect(description.source_type).to eq(task.class.name)
      expect(description.source_id).to eq(task.id)
      expect(task.reload.status).to eq('fetched')
    end
  end

  describe '#add_identity!' do
    subject(:call) { task.add_identity!('wikidata', 'Q892') }

    let(:author) { create(:author) }
    let(:external_identity) { create(:external_identity, owner: author, external_id: 'OL26320A') }
    let(:task) { create(:open_library_author_fetch_task, target: external_identity, status: :fetched) }

    it 'creates an author external identity' do
      identity = call
      expect(identity.external_resource).to eq('wikidata')
      expect(identity.external_id).to eq('Q892')
      expect(author.external_identities.find_by!(external_resource: :wikidata, external_id: 'Q892')).to eq(identity)
    end

    context 'when the resource is unsupported' do
      subject(:call) { task.add_identity!('viaf', '95218067') }

      it 'raises' do
        expect { call }.to raise_error(ArgumentError, 'Invalid external resource')
      end
    end
  end

  describe '#add_link!' do
    subject(:call) { task.add_link!('https://en.wikipedia.org/wiki/J._R._R._Tolkien', external_resource: 'wikipedia') }

    let(:author) { create(:author) }
    let(:external_identity) { create(:external_identity, owner: author, external_id: 'OL26320A') }
    let(:task) { create(:open_library_author_fetch_task, target: external_identity, status: :fetched) }

    it 'creates an author external link' do
      expect { call }.to change(author.external_links, :count).by(1)
      link = call
      expect(link.external_resource).to eq('wikipedia')
      expect(link.url).to eq('https://en.wikipedia.org/wiki/J._R._R._Tolkien')
      expect(link).to be_previously_new_record
    end

    context 'when a link with the same URL already exists' do
      let!(:existing_link) do
        create(
          :external_link,
          owner: author,
          external_resource: 'Homepage',
          url: 'https://en.wikipedia.org/wiki/J._R._R._Tolkien'
        )
      end

      it 'updates the existing link label' do
        expect { call }.not_to change(author.external_links, :count)
        expect(existing_link.reload.external_resource).to eq('wikipedia')
        expect(call).not_to be_previously_new_record
      end
    end
  end
end
