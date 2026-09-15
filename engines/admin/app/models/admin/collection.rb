# frozen_string_literal: true

# == Schema Information
#
# Table name: collections
# Database name: primary
#
#  id             :integer          not null, primary key
#  name           :string           not null
#  year_published :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_collections_on_name  (name) UNIQUE
#
module Admin
  class Collection < ::Collection
    include Admin::HasWikipedia
    include Admin::HasExternalIdentities

    accepts_nested_attributes_for :book_collections, allow_destroy: true

    def readonly?
      false
    end

    def self.cast(collection)
      return collection if collection.is_a?(self)
      return new(collection.attributes) if collection.new_record?

      collection.becomes(self)
    end

    def book_ids=(new_book_ids)
      previous_book_ids = book_collections.map(&:book_id)
      new_book_ids = new_book_ids.uniq.compact_blank
      book_collections.each do |book_collection|
        book_collection.mark_for_destruction unless new_book_ids.include?(book_collection.book_id)
      end
      (new_book_ids - previous_book_ids).each do |id|
        book_collections.build(book_id: id)
      end
    end
  end
end
