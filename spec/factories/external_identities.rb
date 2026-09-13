# frozen_string_literal: true

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
FactoryBot.define do
  factory :external_identity, class: 'ExternalIdentity' do
    owner { association :book }
    external_resource { :open_library }
    sequence(:external_id) { |i| "OL#{i}W" }
  end
end
