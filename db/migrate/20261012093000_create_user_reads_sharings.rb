# frozen_string_literal: true

class CreateUserReadsSharings < ActiveRecord::Migration[8.1]
  def change
    create_table :user_reads_sharings do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :code, null: false

      t.timestamps
    end

    add_index :user_reads_sharings, :code, unique: true
  end
end
