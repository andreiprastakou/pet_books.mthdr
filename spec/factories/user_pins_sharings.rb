# frozen_string_literal: true

# == Schema Information
#
# Table name: user_pins_sharings
# Database name: primary
#
#  id         :integer          not null, primary key
#  code       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_user_pins_sharings_on_code     (code) UNIQUE
#  index_user_pins_sharings_on_user_id  (user_id) UNIQUE
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
FactoryBot.define do
  factory :user_pins_sharing do
    user
    code { SecureRandom.hex(8) }
  end
end
