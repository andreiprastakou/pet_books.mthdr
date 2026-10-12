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

  # Marks the book read. A collection that includes works also marks those works,
  # leaving works that were already read unchanged. Returns the included work ids.
  def self.mark!(user, book)
    create_read!(user.id, book.id)
    work_ids = included_work_ids(book)
    return [] if work_ids.empty?

    already_read = where(user_id: user.id, book_id: work_ids).pluck(:book_id)
    (work_ids - already_read).each { |work_id| create_read!(user.id, work_id) }
    work_ids
  end

  # One index lookup for a page of books: WHERE user_id = ? AND book_id IN (?).
  def self.read_ids_among(user, book_ids)
    ids = Array(book_ids).compact
    return [] if ids.empty?

    where(user_id: user.id, book_id: ids).pluck(:book_id)
  end

  def self.create_read!(user_id, book_id)
    find_or_create_by!(user_id: user_id, book_id: book_id)
  rescue ActiveRecord::RecordNotUnique
    nil
  end
  private_class_method :create_read!

  def self.included_work_ids(book)
    return [] unless book.collection?

    book.collected_works.ids
  end
  private_class_method :included_work_ids
end
