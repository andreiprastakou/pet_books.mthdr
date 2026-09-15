# frozen_string_literal: true

# == Schema Information
#
# Table name: wikidata_lookup_entities
# Database name: primary
#
#  id          :integer          not null, primary key
#  description :string
#  fetched_at  :datetime
#  label       :string
#  qid         :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_wikidata_lookup_entities_on_qid  (qid) UNIQUE
#
FactoryBot.define do
  factory :wikidata_lookup_entity, class: 'WikidataLookupEntity' do
    sequence(:qid) { |i| "Q#{i}" }
    label { "Entity #{qid}" }
    description { "Description for #{qid}" }
    fetched_at { Time.current }
  end
end
