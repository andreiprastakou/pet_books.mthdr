# frozen_string_literal: true

# == Schema Information
#
# Table name: external_api_rate_limits
# Database name: primary
#
#  id                   :integer          not null, primary key
#  last_requested_at    :datetime
#  min_interval_seconds :float            not null
#  name                 :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_external_api_rate_limits_on_name  (name) UNIQUE
#
FactoryBot.define do
  factory :external_api_rate_limit, class: 'ExternalApiRateLimit' do
    sequence(:name) { |i| "api_#{i}" }
    min_interval_seconds { 1.0 / 3 }
    last_requested_at { nil }
  end
end
