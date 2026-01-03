# frozen_string_literal: true

# == Schema Information
#
# Table name: public_lists
# Database name: primary
#
#  id                  :integer          not null, primary key
#  wiki_url            :string
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
  subject { build(:public_list) }

  describe 'associations' do
    it { is_expected.to belong_to(:public_list_type).class_name(PublicListType.name).required }
    it { is_expected.to have_many(:book_public_lists).class_name(BookPublicList.name).dependent(:destroy) }
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
end
