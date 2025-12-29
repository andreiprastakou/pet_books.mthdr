# frozen_string_literal: true

# == Schema Information
#
# Table name: book_series
# Database name: primary
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  book_id    :integer          not null
#  series_id  :integer          not null
#
# Indexes
#
#  index_book_series_on_book_id                (book_id)
#  index_book_series_on_book_id_and_series_id  (book_id,series_id) UNIQUE
#  index_book_series_on_series_id              (series_id)
#
# Foreign Keys
#
#  book_id    (book_id => books.id)
#  series_id  (series_id => series.id)
#
require 'rails_helper'

RSpec.describe BookSeries do
  subject { build(:book_series) }

  describe 'associations' do
    it { is_expected.to belong_to(:series).required }
    it { is_expected.to belong_to(:book).required }
  end

  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:book_series)).to be_valid
    end
  end
end
