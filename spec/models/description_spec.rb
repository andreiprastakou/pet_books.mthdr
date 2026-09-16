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
require 'rails_helper'

RSpec.describe Description do
  subject(:description) { build(:description) }

  describe 'associations' do
    it { is_expected.to belong_to(:owner) }
    it { is_expected.to belong_to(:source).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:text) }
    it { is_expected.to validate_presence_of(:owner_type) }
    it { is_expected.to validate_presence_of(:priority) }
    it { is_expected.to validate_numericality_of(:priority).only_integer }

    it 'has a valid factory' do
      expect(build(:description)).to be_valid
    end
  end
end
