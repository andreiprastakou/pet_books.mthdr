# == Schema Information
#
# Table name: generic_links
# Database name: primary
#
#  id          :integer          not null, primary key
#  entity_type :string           not null
#  locale      :string
#  name        :string           not null
#  url         :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  entity_id   :integer          not null
#
# Indexes
#
#  index_generic_links_on_entity_type_and_entity_id  (entity_type,entity_id)
#
FactoryBot.define do
  factory :generic_link, class: 'GenericLink' do
    sequence(:name) { |i| "LINK_#{i}" }
    sequence(:url) { |i| "https://example.com/link_#{i}" }
  end
end
