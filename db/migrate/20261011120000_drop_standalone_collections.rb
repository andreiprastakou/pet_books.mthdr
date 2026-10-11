# frozen_string_literal: true

class DropStandaloneCollections < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL.squish
      DELETE FROM admin_data_fetch_tasks
      WHERE target_type IN ('Collection', 'Admin::Collection')
         OR (
           target_type = 'Admin::ExternalIdentity'
           AND target_id IN (
             SELECT id FROM external_identities
             WHERE owner_type IN ('Collection', 'Admin::Collection')
           )
         )
    SQL
    execute "DELETE FROM external_identities WHERE owner_type IN ('Collection', 'Admin::Collection')"
    execute "DELETE FROM external_links WHERE owner_type = 'Collection'"
    execute "DELETE FROM wiki_links WHERE entity_type = 'Collection'"

    drop_table :book_collection_legacies
    drop_table :collections
  end

  def down
    create_table :collections do |t|
      t.string :name, null: false
      t.integer :year_published, null: false
      t.timestamps
    end
    add_index :collections, :name, unique: true

    create_table :book_collection_legacies do |t|
      t.references :book, null: false, foreign_key: true
      t.references :collection, null: false, foreign_key: true, index: true
      t.timestamps
    end
    add_index :book_collection_legacies, %i[collection_id book_id], unique: true
  end
end
