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

RSpec.describe PublicListType do
  describe 'associations' do
    it { is_expected.to have_many(:public_lists).class_name(PublicList.name).dependent(:restrict_with_error) }
  end

  describe 'validation' do
    subject { build(:public_list_type) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }

    it 'has a valid factory' do
      expect(build(:public_list_type)).to be_valid
    end
  end

  describe '#==' do
    it 'equates Admin::PublicListType and PublicListType with the same id' do
      admin_public_list_type = create(:public_list_type)
      expect(described_class.find(admin_public_list_type.id)).to eq(admin_public_list_type)
    end
  end

  describe '#readonly?' do
    it 'is readonly' do
      expect(described_class.new).to be_readonly
      expect(described_class.find(create(:public_list_type).id)).to be_readonly
    end

    it 'rejects persistence' do
      public_list_type = described_class.find(create(:public_list_type).id)
      expect { public_list_type.update!(name: 'OTHER') }.to raise_error(ActiveRecord::ReadOnlyRecord)
    end
  end

  it_behaves_like 'has external links'
end
