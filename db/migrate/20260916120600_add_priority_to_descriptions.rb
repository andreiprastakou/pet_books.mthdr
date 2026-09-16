# frozen_string_literal: true

class AddPriorityToDescriptions < ActiveRecord::Migration[8.1]
  def change
    add_column :descriptions, :priority, :integer, null: false, default: 0

    remove_index :descriptions, %i[owner_type owner_id]
    add_index :descriptions, %i[owner_type owner_id priority]
  end
end
