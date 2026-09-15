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
# Indexes
#
#  index_public_list_types_on_name  (name) UNIQUE
#
require 'rails_helper'

RSpec.describe Admin::PublicListType do
  it 'has a valid factory' do
    expect(build(:admin_public_list_type)).to be_valid
  end

  it_behaves_like 'has wikipedia' do
    let(:record) { build(:admin_public_list_type) }
  end

  describe '#readonly?' do
    it 'is writable' do
      expect(described_class.new).not_to be_readonly
      expect(create(:admin_public_list_type)).not_to be_readonly
    end
  end
end
