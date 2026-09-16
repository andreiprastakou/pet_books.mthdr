# frozen_string_literal: true

# == Schema Information
#
# Table name: descriptions
# Database name: primary
#
#  id           :integer          not null, primary key
#  owner_type   :string           not null
#  priority     :integer          default(0), not null
#  source_label :string
#  source_type  :string
#  text         :text             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  owner_id     :integer          not null
#  source_id    :integer
#
# Indexes
#
#  index_descriptions_on_owner_type_and_owner_id_and_priority  (owner_type,owner_id,priority)
#  index_descriptions_on_source_type_and_source_id             (source_type,source_id)
#
FactoryBot.define do
  factory :description, class: 'Description' do
    sequence(:text) { |i| "Description text #{i}" }
    owner { association :book }
  end
end
