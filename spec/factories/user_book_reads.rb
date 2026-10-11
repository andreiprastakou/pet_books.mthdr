# frozen_string_literal: true

# == Schema Information
#
# Table name: user_book_reads
# Database name: primary
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  book_id    :integer          not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_user_book_reads_on_book_id              (book_id)
#  index_user_book_reads_on_user_id_and_book_id  (user_id,book_id) UNIQUE
#
# Foreign Keys
#
#  book_id  (book_id => books.id)
#  user_id  (user_id => users.id)
#
FactoryBot.define do
  factory :user_book_read do
    user
    book
  end
end
