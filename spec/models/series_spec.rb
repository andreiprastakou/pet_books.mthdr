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

RSpec.describe Series do
  subject { build(:series) }

  describe 'associations' do
    it { is_expected.to have_many(:book_series).class_name(BookSeries.name) }
    it { is_expected.to have_many(:books).class_name(Book.name).through(:book_series) }
  end

  describe 'validation' do
    subject { build(:series) }

    it { is_expected.to validate_presence_of(:name) }

    it 'has a valid factory' do
      expect(build(:series)).to be_valid
    end
  end
end

