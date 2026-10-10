# frozen_string_literal: true

class RenameBookCollectionsToLegacyAndRecreate < ActiveRecord::Migration[8.1]
  def change
    rename_table :book_collections, :book_collection_legacies

    # collection_id is the leading column of the unique index, so a separate
    # index_book_collections_on_collection_id is redundant.
    create_table :book_collections do |t|
      t.references :collection, null: false, foreign_key: { to_table: :books }, index: false
      t.references :book, null: false, foreign_key: true
      t.timestamps
    end

    add_index :book_collections, %i[collection_id book_id], unique: true
  end
end
