class RemoveAuthorIdFromBooks < ActiveRecord::Migration[8.1]
  def change
    remove_index :books, %i[title author_id], unique: true
    remove_column :books, :author_id, :integer, null: false, index: true
  end
end
