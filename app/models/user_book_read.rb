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
class UserBookRead < ApplicationRecord
  belongs_to :user
  belongs_to :book

  validates :book_id, uniqueness: { scope: :user_id }

  def self.read?(user, book)
    exists?(user_id: user.id, book_id: book.id)
  end

  # One index lookup for a page of books: WHERE user_id = ? AND book_id IN (?).
  def self.read_ids_among(user, book_ids)
    ids = Array(book_ids).compact
    return [] if ids.empty?

    where(user_id: user.id, book_id: ids).pluck(:book_id)
  end
end
