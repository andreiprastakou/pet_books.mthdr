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
#  index_book_series_on_book_id    (book_id)
#  index_book_series_on_series_id  (series_id)
#
# Foreign Keys
#
#  book_id    (book_id => books.id)
#  series_id  (series_id => series.id)
#
FactoryBot.define do
  factory :book_series, class: 'BookSeries' do
    series factory: %i[series], strategy: :create
    book factory: %i[book], strategy: :create
  end
end

