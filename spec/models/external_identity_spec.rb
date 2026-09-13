# frozen_string_literal: true

require 'rails_helper'

# == Schema Information
#
# Table name: external_identities
# Database name: primary
#
#  id                :integer          not null, primary key
#  external_resource :integer          not null
#  owner_type        :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  external_id       :string           not null
#  external_link_id  :integer
#  owner_id          :integer          not null
#
# Indexes
#
#  index_external_identities_on_external_link_id                   (external_link_id)
#  index_external_identities_on_external_resource_and_external_id  (external_resource,external_id) UNIQUE
#  index_external_identities_on_owner_type_and_owner_id            (owner_type,owner_id)
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
    it { is_expected.to validate_presence_of(:external_id) }
    it { is_expected.to validate_uniqueness_of(:external_id).scoped_to(:external_resource) }

    it 'has a valid factory' do
      expect(build(:external_identity, owner: build_stubbed(:book))).to be_valid
    end

    it 'allows blank external_link' do
      identity = build(:external_identity, external_link: nil)
      expect(identity).to be_valid
    end
  end
end
