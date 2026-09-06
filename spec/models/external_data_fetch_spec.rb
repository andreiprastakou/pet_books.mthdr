# frozen_string_literal: true

require 'rails_helper'

# == Schema Information
#
# Table name: external_data_fetches
# Database name: primary
#
#  id                   :integer          not null, primary key
#  data                 :json
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  external_identity_id :integer          not null
#
# Indexes
#
#  index_external_data_fetches_on_external_identity_id  (external_identity_id)
#
# Foreign Keys
#
#  external_identity_id  (external_identity_id => external_identities.id)
#
RSpec.describe ExternalDataFetch do
  subject(:data_fetch) { build(:external_data_fetch) }

  describe 'associations' do
    it { is_expected.to belong_to(:external_identity).class_name(ExternalIdentity.name) }
  end

  describe 'validations' do
    it 'has a valid factory' do
      expect(build(:external_data_fetch)).to be_valid
    end

    it 'allows blank data' do
      expect(build(:external_data_fetch, data: nil)).to be_valid
    end
  end
end
