# == Schema Information
#
# Table name: genres
# Database name: primary
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  cover_design_id :integer
#
# Indexes
#
#  index_genres_on_cover_design_id  (cover_design_id)
#  index_genres_on_name             (name) UNIQUE
#
# Foreign Keys
#
#  cover_design_id  (cover_design_id => cover_designs.id)
#
FactoryBot.define do
  factory :genre, class: 'Genre' do
    name { 'literary' }
  end
end
