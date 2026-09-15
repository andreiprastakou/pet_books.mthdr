# frozen_string_literal: true

# == Schema Information
#
# Table name: public_lists
# Database name: primary
#
#  id                  :integer          not null, primary key
#  year                :integer          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  public_list_type_id :integer          not null
#
# Indexes
#
#  index_public_lists_on_public_list_type_id           (public_list_type_id)
#  index_public_lists_on_public_list_type_id_and_year  (public_list_type_id,year) UNIQUE
#
# Foreign Keys
#
#  public_list_type_id  (public_list_type_id => public_list_types.id)
#
require 'rails_helper'

RSpec.describe Admin::PublicList do
  it 'has a valid factory' do
    expect(build(:admin_public_list)).to be_valid
  end

  it_behaves_like 'has wikipedia' do
    let(:record) { build(:admin_public_list) }
  end

  describe '#readonly?' do
    it 'is writable' do
      expect(described_class.new).not_to be_readonly
      expect(create(:admin_public_list)).not_to be_readonly
    end
  end
end
