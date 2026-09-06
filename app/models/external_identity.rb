# frozen_string_literal: true

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
class ExternalIdentity < ApplicationRecord
  belongs_to :owner, polymorphic: true, inverse_of: :external_identities
  has_many :external_data_fetches, class_name: 'ExternalDataFetch', dependent: :destroy,
                                   inverse_of: :external_identity

  enum :external_resource, {
    open_library: 1,
    wikidata: 2,
    librarything: 3,
    goodreads: 4
  }

  validates :owner_type, presence: true
  validates :external_resource, presence: true
  validates :identificator, uniqueness: { scope: :external_resource }, allow_nil: true
end
