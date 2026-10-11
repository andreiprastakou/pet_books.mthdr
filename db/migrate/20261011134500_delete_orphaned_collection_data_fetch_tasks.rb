# frozen_string_literal: true

class DeleteOrphanedCollectionDataFetchTasks < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL.squish
      DELETE FROM admin_data_fetch_tasks
      WHERE target_type IN ('Collection', 'Admin::Collection')
         OR (
           target_type = 'Admin::ExternalIdentity'
           AND target_id NOT IN (SELECT id FROM external_identities)
         )
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
