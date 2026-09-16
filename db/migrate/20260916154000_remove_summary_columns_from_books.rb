# frozen_string_literal: true

class RemoveSummaryColumnsFromBooks < ActiveRecord::Migration[8.1]
  def change
    remove_column :books, :summary, :text
    remove_column :books, :summary_src, :string
  end
end
