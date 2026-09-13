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
FactoryBot.define do
  factory :external_link, class: 'ExternalLink' do
    sequence(:external_resource) { |i| "LINK_#{i}" }
    sequence(:url) { |i| "https://example.com/link_#{i}" }
  end
end
