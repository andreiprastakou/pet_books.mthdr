# frozen_string_literal: true

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
class ExternalDataFetch < ApplicationRecord
  belongs_to :external_identity, class_name: 'ExternalIdentity', inverse_of: :external_data_fetches
end
