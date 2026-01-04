# frozen_string_literal: true

# == Schema Information
#
# Table name: public_list_types
# Database name: primary
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  wiki_url   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_public_list_types_on_name  (name) UNIQUE
#
require 'rails_helper'

RSpec.describe PublicListType do
  subject { build(:public_list_type) }

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

  it_behaves_like 'has wiki links' do
    let(:record) { build(:public_list_type) }
  end

  it_behaves_like 'has generic links'
end
