class CreateBookSeries < ActiveRecord::Migration[8.1]
  def change
    create_table :book_series do |t|
      t.references :series, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.timestamps
    end
  end
end
