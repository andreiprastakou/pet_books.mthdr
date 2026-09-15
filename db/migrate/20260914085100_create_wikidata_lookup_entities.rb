# frozen_string_literal: true

class CreateWikidataLookupEntities < ActiveRecord::Migration[8.1]
  def change
    create_table :wikidata_lookup_entities do |t|
      t.string :qid, null: false
      t.string :label
      t.string :description
      t.datetime :fetched_at

      t.timestamps
    end

    add_index :wikidata_lookup_entities, :qid, unique: true
  end
end
