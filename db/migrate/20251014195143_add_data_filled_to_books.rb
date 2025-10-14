class AddDataFilledToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :data_filled, :boolean, default: false, null: false
    add_index :books, :data_filled

    execute <<-SQL
      UPDATE books SET data_filled = true WHERE summary IS NOT NULL
    SQL
  end
end
