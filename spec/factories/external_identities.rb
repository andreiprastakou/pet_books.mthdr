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
FactoryBot.define do
  factory :external_identity, class: 'ExternalIdentity' do
    owner { association :book }
    external_resource { :open_library }
    sequence(:identificator) { |i| "OL#{i}W" }
  end
end
