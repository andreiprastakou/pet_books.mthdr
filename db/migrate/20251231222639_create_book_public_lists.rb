class CreateBookPublicLists < ActiveRecord::Migration[8.1]
  def change
    create_table :book_public_lists do |t|
      t.references :book, null: false, foreign_key: true
      t.references :public_list, null: false, foreign_key: true
      t.string :role
      t.timestamps
    end

    add_index :book_public_lists, %i[book_id public_list_id], unique: true
  end
end
