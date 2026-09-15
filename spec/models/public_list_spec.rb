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

RSpec.describe PublicList do
  describe 'associations' do
    it { is_expected.to belong_to(:public_list_type).class_name(PublicListType.name).required }
    it { is_expected.to have_many(:book_public_lists).class_name(Joins::BookPublicList.name).dependent(:destroy) }
    it { is_expected.to have_many(:books).class_name(Book.name).through(:book_public_lists) }
  end

  describe 'validation' do
    subject { build(:public_list) }

    it { is_expected.to validate_presence_of(:year) }
    it { is_expected.to validate_numericality_of(:year).only_integer.is_greater_than(0) }

    it 'has a valid factory' do
      expect(build(:public_list)).to be_valid
    end

    it 'validates uniqueness of year per public_list_type' do
      public_list_type = create(:public_list_type)
      create(:public_list, public_list_type: public_list_type, year: 2020)
      duplicate = build(:public_list, public_list_type: public_list_type, year: 2020)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:public_list_type_id]).to be_present
    end
  end

  describe '#==' do
    it 'equates Admin::PublicList and PublicList with the same id' do
      admin_public_list = create(:public_list)
      expect(described_class.find(admin_public_list.id)).to eq(admin_public_list)
    end
  end

  describe '#readonly?' do
    it 'is readonly' do
      expect(described_class.new).to be_readonly
      expect(described_class.find(create(:public_list).id)).to be_readonly
    end

    it 'rejects persistence' do
      public_list = described_class.find(create(:public_list).id)
      expect { public_list.update!(year: 1999) }.to raise_error(ActiveRecord::ReadOnlyRecord)
    end
  end

  it_behaves_like 'has external links'
end
