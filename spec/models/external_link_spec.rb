# == Schema Information
#
# Table name: external_links
# Database name: primary
#
#  id                :integer          not null, primary key
#  external_resource :string           not null
#  locale            :string
#  owner_type        :string           not null
#  url               :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  owner_id          :integer          not null
#
# Indexes
#
#  index_external_links_on_owner_type_and_owner_id  (owner_type,owner_id)
#
require 'rails_helper'

RSpec.describe ExternalLink do
  subject(:link) { build(:external_link) }

  describe 'associations' do
    it { is_expected.to belong_to(:owner).optional }
    it { is_expected.to have_many(:external_identities).dependent(:nullify) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:owner_type) }
    it { is_expected.to validate_presence_of(:external_resource) }
    it { is_expected.to validate_presence_of(:url) }

    it 'has a valid factory' do
      expect(build(:external_link, owner: build_stubbed(:book))).to be_valid
    end
  end
end
