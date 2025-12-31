class CreatePublicLists < ActiveRecord::Migration[8.1]
  def change
    create_table :public_lists do |t|
      t.references :public_list_type, null: false, foreign_key: true
      t.integer :year, null: false
      t.timestamps
    end

    add_index :public_lists, %i[public_list_type_id year], unique: true
  end
end
