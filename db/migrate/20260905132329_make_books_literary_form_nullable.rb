# frozen_string_literal: true

class MakeBooksLiteraryFormNullable < ActiveRecord::Migration[8.1]
  def change
    change_column_null :books, :literary_form, true
    change_column_default :books, :literary_form, from: 'novel', to: nil
  end
end
