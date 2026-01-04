class CreateGenericLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :generic_links do |t|
      t.string :url, null: false
      t.string :locale
      t.string :name, null: false
      t.string :entity_type, null: false
      t.integer :entity_id, null: false
      t.timestamps

      t.index %i[entity_type entity_id]
    end
  end
end
