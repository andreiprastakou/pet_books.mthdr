# frozen_string_literal: true

class RenameExternalLinkNameAndEntity < ActiveRecord::Migration[8.1]
  def change
    rename_column :external_links, :name, :external_resource
    rename_column :external_links, :entity_type, :owner_type
    rename_column :external_links, :entity_id, :owner_id
    rename_index :external_links,
                 'index_external_links_on_entity_type_and_entity_id',
                 'index_external_links_on_owner_type_and_owner_id'
  end
end
