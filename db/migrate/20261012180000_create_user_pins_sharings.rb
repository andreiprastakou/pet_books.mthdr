# frozen_string_literal: true

class CreateUserPinsSharings < ActiveRecord::Migration[8.1]
  def change
    create_table :user_pins_sharings do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :code, null: false

      t.timestamps
    end

    add_index :user_pins_sharings, :code, unique: true
  end
end
