class CreateBookCollections < ActiveRecord::Migration[8.1]
  def change
    create_table :book_collections do |t|
      t.references :collection, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.timestamps
    end

    add_index :book_collections, %i[collection_id book_id], unique: true
  end
end
