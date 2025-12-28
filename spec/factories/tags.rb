# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
# Database name: primary
#
#  id         :integer          not null, primary key
#  category   :integer          default("other")
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_tags_on_category  (category)
#  index_tags_on_name      (name) UNIQUE
#
FactoryBot.define do
  factory :tag, class: 'Tag' do
    sequence(:name) { |i| "Tag#{i}" }
  end
end
