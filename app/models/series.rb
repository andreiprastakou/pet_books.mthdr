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
class Series < ApplicationRecord
  has_many :book_series, class_name: 'BookSeries', dependent: :destroy
  has_many :books, class_name: 'Book', through: :book_series

  validates :name, presence: true
end

