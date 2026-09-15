# frozen_string_literal: true

class RenameExternalIdentityPolymorphicTargetType < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL.squish
      UPDATE admin_data_fetch_tasks
      SET target_type = 'Admin::ExternalIdentity'
      WHERE target_type = 'ExternalIdentity'
    SQL
  end

  def down
    execute <<~SQL.squish
      UPDATE admin_data_fetch_tasks
      SET target_type = 'ExternalIdentity'
      WHERE target_type = 'Admin::ExternalIdentity'
    SQL
  end
end
