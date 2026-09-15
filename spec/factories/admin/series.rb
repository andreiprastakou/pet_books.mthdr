# frozen_string_literal: true

# == Schema Information
#
# Table name: series
# Database name: primary
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_series_on_name  (name)
#
FactoryBot.define do
  factory :admin_series, class: 'Admin::Series', parent: :series
end
