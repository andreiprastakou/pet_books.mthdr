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
#  url               :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  owner_id          :integer          not null
#
# Indexes
#
#  idx_on_external_resource_identificator_ab3aeda95b     (external_resource,identificator) UNIQUE
#  index_external_identities_on_owner_type_and_owner_id  (owner_type,owner_id)
#
RSpec.describe ExternalIdentity do
  subject(:identity) { build(:external_identity) }

  describe 'associations' do
    it { is_expected.to belong_to(:owner) }
    it { is_expected.to have_many(:external_data_fetches).class_name(ExternalDataFetch.name).dependent(:destroy) }
    it {
      is_expected.to have_many(:open_library_fetch_tasks).class_name(Admin::OpenLibraryFetchTask.name)
                                                        .dependent(:destroy)
    }
  end

  describe '#external_resource enum' do
    it do
      expect(identity).to define_enum_for(:external_resource).with_values(
        open_library: 1,
        wikidata: 2,
        librarything: 3,
        goodreads: 4
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

    it 'allows blank identificator and url' do
      identity = build(:external_identity, identificator: nil, url: nil)
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

    it 'does not enqueue when the owner is not a book' do
      author = create(:author)

      expect do
        create(:external_identity, owner: author, external_resource: :open_library)
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
