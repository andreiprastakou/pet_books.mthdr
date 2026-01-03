# == Schema Information
#
# Table name: collections
# Database name: primary
#
#  id             :integer          not null, primary key
#  name           :string           not null
#  wiki_url       :string
#  year_published :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_collections_on_name  (name) UNIQUE
#
FactoryBot.define do
  factory :collection, class: 'Collection' do
    sequence(:name) { |i| "Collection #{i}" }
    year_published { rand(1990..2025) }
  end
end
