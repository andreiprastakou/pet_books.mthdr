# frozen_string_literal: true

# == Schema Information
#
# Table name: books
# Database name: primary
#
#  id                   :integer          not null, primary key
#  data_filled          :boolean          default(FALSE), not null
#  goodreads_popularity :integer
#  goodreads_rating     :float
#  goodreads_url        :string
#  literary_form        :string           default("novel"), not null
#  original_title       :string
#  popularity           :integer          default(0)
#  summary              :text
#  summary_src          :string
#  title                :string           not null
#  wiki_popularity      :integer          default(0)
#  wiki_url             :string
#  year_published       :integer          not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_books_on_data_filled     (data_filled)
#  index_books_on_year_published  (year_published)
#
FactoryBot.define do
  factory :book, class: 'Book' do
    sequence(:title) { |i| "Book #{i}" }
    year_published { rand(1992..2021) }
    authors { create_list(:author, 1) }
  end
end
