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
#  index_book_collections_on_collection_id              (collection_id)
#  index_book_collections_on_collection_id_and_book_id  (collection_id,book_id) UNIQUE
#
# Foreign Keys
#
#  book_id        (book_id => books.id)
#  collection_id  (collection_id => collections.id)
#
FactoryBot.define do
  factory :book_collection, class: 'BookCollection'
end
