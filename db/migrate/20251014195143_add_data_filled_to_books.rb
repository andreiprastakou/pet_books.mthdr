class AddDataFilledToBooks < ActiveRecord::Migration[8.0]
  def up
    add_column :books, :data_filled, :boolean, default: false, null: false
    add_index :books, :data_filled

    execute <<-SQL.squish
      UPDATE books SET data_filled = true WHERE summary IS NOT NULL
    SQL
  end

  def down
    remove_index :books, :data_filled
    remove_column :books, :data_filled
  end
end
