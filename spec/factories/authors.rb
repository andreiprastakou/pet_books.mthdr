# frozen_string_literal: true

# == Schema Information
#
# Table name: authors
# Database name: primary
#
#  id                :integer          not null, primary key
#  aws_photos        :json
#  birth_year        :integer
#  death_year        :integer
#  fullname          :string           not null
#  original_fullname :string
#  reference         :string
#  synced_at         :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_authors_on_fullname  (fullname) UNIQUE
#

FactoryBot.define do
  factory :author, class: 'Author' do
    sequence(:fullname) { |i| "King Henry #{i}" }
  end
end
