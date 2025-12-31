# frozen_string_literal: true

# == Schema Information
#
# Table name: public_list_types
# Database name: primary
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :public_list_type, class: 'PublicListType' do
    sequence(:name) { |i| "Public List Type #{i}" }
  end
end

