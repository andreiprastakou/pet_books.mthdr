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

RSpec.describe Admin::Author do
  it 'has a valid factory' do
    expect(build(:admin_author)).to be_valid
  end

  describe 'associations' do
    it {
      is_expected.to have_many(:books_list_tasks).class_name(Admin::AuthorBooksListTask.name)
                                                 .dependent(:destroy)
    }
    it {
      is_expected.to have_many(:list_parsing_tasks).class_name(Admin::AuthorBooksListParsingTask.name)
                                                   .dependent(:destroy)
    }
    it do
      is_expected.to have_many(:open_library_author_search_tasks)
        .class_name(Admin::OpenLibraryAuthorSearchTask.name)
        .dependent(:destroy)
    end
    it { is_expected.to have_many(:external_identities).class_name(Admin::ExternalIdentity.name).dependent(:destroy) }
    it { is_expected.to have_many(:wiki_links).class_name(WikiLink.name).dependent(:destroy) }
  end

  it_behaves_like 'has wikipedia' do
    let(:record) { build(:admin_author) }
  end

  describe '#readonly?' do
    it 'is writable' do
      expect(described_class.new).not_to be_readonly
      expect(create(:admin_author)).not_to be_readonly
    end
  end

  describe 'scopes' do
    describe '.not_synced' do
      subject(:result) { described_class.not_synced }

      before { authors }

      let(:authors) do
        [
          create(:author, synced_at: nil),
          create(:author, synced_at: Time.current)
        ]
      end

      it 'returns authors that are not synced' do
        expect(result).to match_array(authors.values_at(0))
      end
    end

    describe '.without_tasks' do
      subject(:result) { described_class.without_tasks }

      before do
        authors
        create(:author_books_list_task, target: authors[1])
      end

      let(:authors) { create_list(:author, 2) }

      it 'returns authors that have no list tasks' do
        expect(result).to match_array(authors.values_at(0))
      end
    end
  end

  describe '#history_data_fetch_tasks' do
    subject(:result) { author.history_data_fetch_tasks }

    let(:author) { create(:admin_author) }
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
