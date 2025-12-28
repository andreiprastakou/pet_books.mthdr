class CreateSeries < ActiveRecord::Migration[8.1]
  def change
    create_table :series do |t|
      t.string :name, null: false, index: true
      t.timestamps
    end
  end
end
