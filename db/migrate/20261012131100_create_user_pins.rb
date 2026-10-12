# frozen_string_literal: true

class CreateUserPins < ActiveRecord::Migration[8.1]
  def change
    create_table :user_pins do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.references :entity, polymorphic: true, null: false, index: false

      t.timestamps
    end

    add_index :user_pins, %i[user_id entity_type entity_id], unique: true
    add_index :user_pins, %i[entity_type entity_id]
  end
end
