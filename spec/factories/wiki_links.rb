# == Schema Information
#
# Table name: wiki_links
# Database name: primary
#
#  id               :integer          not null, primary key
#  entity_type      :string           not null
#  locale           :string           not null
#  name             :string           not null
#  url              :string           not null
#  views            :integer
#  views_last_month :integer
#  views_synced_at  :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  entity_id        :integer          not null
#
# Indexes
#
#  index_wiki_page_stats_on_entity  (entity_type,entity_id)
#
FactoryBot.define do
  factory :wiki_link, class: 'WikiLink' do
    entity factory: :book, strategy: :build_stubbed
    locale { 'en' }
    sequence(:name) { |i| "Test_#{i}" }
    views { 100 }
    views_last_month { 10 }
    views_synced_at { 1.day.ago.utc }
  end
end
