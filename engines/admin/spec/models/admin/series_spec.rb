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
require 'rails_helper'

RSpec.describe Admin::Series do
  it 'has a valid factory' do
    expect(build(:admin_series)).to be_valid
  end

  it_behaves_like 'has wikipedia' do
    let(:record) { build(:admin_series) }
  end

  describe '#readonly?' do
    it 'is writable' do
      expect(described_class.new).not_to be_readonly
      expect(create(:admin_series)).not_to be_readonly
    end
  end
end
