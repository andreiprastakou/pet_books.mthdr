# frozen_string_literal: true

require 'rails_helper'

# == Schema Information
#
# Table name: external_identities
# Database name: primary
#
#  id                :integer          not null, primary key
#  external_resource :integer          not null
#  identificator     :string
#  owner_type        :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  external_link_id  :integer
#  owner_id          :integer          not null
#
# Indexes
#
#  idx_on_external_resource_identificator_ab3aeda95b     (external_resource,identificator) UNIQUE
#  index_external_identities_on_external_link_id         (external_link_id)
#  index_external_identities_on_owner_type_and_owner_id  (owner_type,owner_id)
#
# Foreign Keys
#
#  external_link_id  (external_link_id => external_links.id) ON DELETE => nullify
#
RSpec.describe ExternalIdentity do
  subject(:identity) { build(:external_identity) }

  describe 'associations' do
    it { is_expected.to belong_to(:owner) }
    it { is_expected.to belong_to(:external_link).optional }
    it {
      is_expected.to have_many(:open_library_fetch_tasks).class_name(Admin::OpenLibraryFetchTask.name)
                                                        .dependent(:destroy)
    }
    it {
      is_expected.to have_many(:open_library_author_fetch_tasks)
        .class_name(Admin::OpenLibraryAuthorFetchTask.name)
        .dependent(:destroy)
    }
  end


  describe '#external_resource enum' do
    it do
      expect(identity).to define_enum_for(:external_resource).with_values(
        ExternalResources::OPEN_LIBRARY => 1,
        ExternalResources::WIKIDATA => 2,
        ExternalResources::LIBRARYTHING => 3,
        ExternalResources::GOODREADS => 4
      )
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:owner_type) }
    it { is_expected.to validate_presence_of(:external_resource) }
    it { is_expected.to validate_uniqueness_of(:identificator).scoped_to(:external_resource).allow_nil }

    it 'has a valid factory' do
      expect(build(:external_identity, owner: build_stubbed(:book))).to be_valid
    end

    it 'allows blank identificator and external_link' do
      identity = build(:external_identity, identificator: nil, external_link: nil)
      expect(identity).to be_valid
    end
  end

  describe 'after create' do
    it 'spawns and enqueues an Open Library fetch task for book open_library identities' do
      book = create(:book)

      expect do
        create(:external_identity, owner: book, external_resource: :open_library)
      end.to change(Admin::OpenLibraryFetchTask, :count).by(1)
                                                        .and have_enqueued_job(Admin::DataFetchJob)
    end

    it 'spawns and enqueues an Open Library author fetch task for author open_library identities' do
      author = create(:author)

      expect do
        create(:external_identity, owner: author, external_resource: :open_library, identificator: 'OL1394865A')
      end.to change(Admin::OpenLibraryAuthorFetchTask, :count).by(1)
                                                             .and have_enqueued_job(Admin::DataFetchJob)
    end

    it 'does not enqueue a book fetch task when the owner is an author' do
      author = create(:author)

      expect do
        create(:external_identity, owner: author, external_resource: :open_library, identificator: 'OL1394865A')
      end.not_to change(Admin::OpenLibraryFetchTask, :count)
    end

    it 'does not enqueue for non-open_library identities' do
      book = create(:book)

      expect do
        create(:external_identity, owner: book, external_resource: :wikidata, identificator: 'Q1')
      end.not_to change(Admin::OpenLibraryFetchTask, :count)
    end
  end
end
