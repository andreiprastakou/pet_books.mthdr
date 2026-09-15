# frozen_string_literal: true

# == Schema Information
#
# Table name: authors
# Database name: primary
#
#  id                :integer          not null, primary key
#  aws_photos        :json
#  birth_year        :integer
#  death_year        :integer
#  fullname          :string           not null
#  original_fullname :string
#  synced_at         :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_authors_on_fullname  (fullname) UNIQUE
#

require 'rails_helper'

RSpec.describe Author do
  describe 'associations' do
    it { is_expected.to have_many(:book_authors).class_name(Joins::BookAuthor.name) }
    it { is_expected.to have_many(:books).class_name(Book.name).through(:book_authors) }
    it { is_expected.to have_many(:tag_connections).class_name(Joins::TagConnection.name) }
    it { is_expected.to have_many(:tags).class_name(Tag.name).through(:tag_connections) }
    it { is_expected.to have_many(:books_list_tasks).class_name(Admin::AuthorBooksListTask.name) }
    it { is_expected.to have_many(:list_parsing_tasks).class_name(Admin::AuthorBooksListParsingTask.name) }
    it do
      is_expected.to have_many(:open_library_author_search_tasks)
        .class_name(Admin::OpenLibraryAuthorSearchTask.name)
    end
    it { is_expected.to have_many(:external_identities).class_name(ExternalIdentity.name).dependent(:destroy) }
  end

  describe 'validation' do
    subject { build(:author) }

    it { is_expected.to validate_presence_of(:fullname) }
    it { is_expected.to validate_uniqueness_of(:fullname) }
    it { is_expected.to validate_numericality_of(:birth_year).only_integer }
    it { is_expected.to validate_numericality_of(:death_year).only_integer }

    it 'has a valid factory' do
      expect(build(:author)).to be_valid
    end
  end

  describe 'before validation' do
    it 'strips the fullname' do
      author = described_class.new(fullname: "   NAME  \n")
      expect { author.valid? }.to change(author, :fullname).to('NAME')
    end
  end

  describe 'scopes' do
    describe '.search_by_name' do
      subject(:result) { described_class.search_by_name(key) }

      let(:key) { 'Fenimore' }
      let(:authors) do
        [
          create(:author, fullname: 'Fenimore Cooper'),
          create(:author, fullname: 'fenimore Fothergill'),
          create(:author, fullname: 'Penimore Fogarty')
        ]
      end

      it 'returns the authors that match the name' do
        expect(result).to match_array(authors.values_at(0, 1))
      end
    end
  end

  it_behaves_like 'has wikipedia' do
    let(:record) { build(:author) }
  end

  it_behaves_like 'has external links'

  describe '#photo_thumb_url' do
    subject(:result) { author.photo_thumb_url }

    let(:author) { build(:author) }
    let(:aws_photos) { instance_double(Uploaders::AwsAuthorPhotoUploader) }

    before do
      allow(author).to receive(:aws_photos).and_return(aws_photos)
      allow(aws_photos).to receive(:url).with(:thumb).and_return('https://example.com/thumb.jpg')
    end

    it 'returns the photo thumb URL' do
      expect(result).to eq('https://example.com/thumb.jpg')
    end
  end

  describe '#photo_card_url' do
    subject(:result) { author.photo_card_url }

    let(:author) { build(:author) }
    let(:aws_photos) { instance_double(Uploaders::AwsAuthorPhotoUploader) }

    before do
      allow(author).to receive(:aws_photos).and_return(aws_photos)
      allow(aws_photos).to receive(:url).with(:card).and_return('https://example.com/card.jpg')
    end

    it 'returns the photo card URL' do
      expect(result).to eq('https://example.com/card.jpg')
    end
  end

  describe '#history_data_fetch_tasks' do
    subject(:result) { author.history_data_fetch_tasks }

    let(:author) { create(:author) }
    let!(:author_task) { create(:open_library_author_search_task, target: author, updated_at: 1.day.ago) }
    let!(:identity_task) do
      identity = create(:external_identity, owner: author, external_resource: :open_library, external_id: 'OL1A')
      create(:open_library_author_fetch_task, target: identity, updated_at: Time.current)
    end

    it 'returns author and identity tasks newest first' do
      expect(result).to eq([identity_task, author_task])
    end
  end
end
