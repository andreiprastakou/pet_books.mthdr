# frozen_string_literal: true

# == Schema Information
#
# Table name: user_pins
# Database name: primary
#
#  id          :integer          not null, primary key
#  entity_type :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  entity_id   :integer          not null
#  user_id     :integer          not null
#
# Indexes
#
#  index_user_pins_on_entity_type_and_entity_id              (entity_type,entity_id)
#  index_user_pins_on_user_id_and_entity_type_and_entity_id  (user_id,entity_type,entity_id) UNIQUE
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
FactoryBot.define do
  factory :user_pin do
    user
    entity { association :book }
  end
end
