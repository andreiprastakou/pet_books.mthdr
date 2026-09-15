# frozen_string_literal: true

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
require 'rails_helper'

RSpec.describe Admin::Genre do
  it 'has a valid factory' do
    expect(build(:admin_genre)).to be_valid
  end

  describe '#readonly?' do
    it 'is writable' do
      expect(described_class.new).not_to be_readonly
      expect(create(:admin_genre)).not_to be_readonly
    end
  end
end
