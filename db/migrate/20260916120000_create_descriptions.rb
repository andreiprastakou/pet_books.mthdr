# frozen_string_literal: true

class CreateDescriptions < ActiveRecord::Migration[8.1]
  class BookStub < ApplicationRecord
    self.table_name = 'books'
  end

  class DescriptionStub < ApplicationRecord
    self.table_name = 'descriptions'
  end

  def up
    create_table :descriptions do |t|
      t.text :text, null: false
      t.string :owner_type, null: false
      t.integer :owner_id, null: false
      t.string :source_type
      t.integer :source_id
      t.string :source_label
      t.timestamps

      t.index %i[owner_type owner_id]
      t.index %i[source_type source_id]
    end

    migrate_book_summaries
  end

  def down
    drop_table :descriptions
  end

  private

  def migrate_book_summaries
    BookStub.where.not(summary: [nil, '']).find_each do |book|
      DescriptionStub.create!(
        text: book.summary,
        owner_type: 'Book',
        owner_id: book.id,
        source_label: "AI: #{book.summary_src}"
      )
    end
  end
end
