class AddNameIndexToPublicListTypes < ActiveRecord::Migration[8.1]
  def change
    add_index :public_list_types, :name, unique: true
  end
end
