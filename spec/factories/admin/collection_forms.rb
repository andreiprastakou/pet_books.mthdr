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
  factory :admin_collection_form, class: 'Admin::CollectionForm', parent: :collection
end
