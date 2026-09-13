# frozen_string_literal: true

class DropExternalDataFetches < ActiveRecord::Migration[8.1]
  def change
    drop_table :external_data_fetches do |t|
      t.references :external_identity, null: false, foreign_key: true
      t.json :data

      t.timestamps
    end
  end
end
