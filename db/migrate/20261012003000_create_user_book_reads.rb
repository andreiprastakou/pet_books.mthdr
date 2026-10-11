# frozen_string_literal: true

class CreateUserBookReads < ActiveRecord::Migration[8.1]
  def change
    create_table :user_book_reads do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.references :book, null: false, foreign_key: true

      t.timestamps
    end

    add_index :user_book_reads, %i[user_id book_id], unique: true
  end
end
