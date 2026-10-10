# frozen_string_literal: true

# == Schema Information
#
# Table name: book_collections
# Database name: primary
#
#  id            :integer          not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  book_id       :integer          not null
#  collection_id :integer          not null
#
# Indexes
#
#  index_book_collections_on_book_id                    (book_id)
#  index_book_collections_on_collection_id_and_book_id  (collection_id,book_id) UNIQUE
#
# Foreign Keys
#
#  book_id        (book_id => books.id)
#  collection_id  (collection_id => books.id)
#
module Joins
  class BookCollection < ApplicationRecord
    self.table_name = 'book_collections'

    belongs_to :book, class_name: 'Book', inverse_of: :book_collections_as_work
    belongs_to :collection, class_name: 'Book', inverse_of: :book_collections_as_collection

    validate :book_and_collection_must_differ
    validate :collection_must_be_a_collection
    validate :book_must_not_be_a_collection

    protected

    def book_and_collection_must_differ
      return if book_id.blank? || collection_id.blank?
      return unless book_id == collection_id

      errors.add(:book, 'must be different from the collection')
    end

    def collection_must_be_a_collection
      return if collection.nil?
      return if collection.collection?

      errors.add(:collection, 'must have literary form collection')
    end

    def book_must_not_be_a_collection
      return if book.nil?
      return unless book.collection?

      errors.add(:book, 'must not have literary form collection')
    end
  end
end
