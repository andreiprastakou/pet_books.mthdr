class AddIndexToBookSeries < ActiveRecord::Migration[8.1]
  def change
    add_index :book_series, %i[book_id series_id], unique: true
  end
end
