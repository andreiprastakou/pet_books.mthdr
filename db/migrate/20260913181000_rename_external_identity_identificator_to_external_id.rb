# frozen_string_literal: true

class RenameExternalIdentityIdentificatorToExternalId < ActiveRecord::Migration[8.1]
  class ExternalIdentityStub < ApplicationRecord
    self.table_name = 'external_identities'
  end

  def up
    rename_column :external_identities, :identificator, :external_id
    rename_index :external_identities,
                 'idx_on_external_resource_identificator_ab3aeda95b',
                 'index_external_identities_on_external_resource_and_external_id'

    blank_count = ExternalIdentityStub.where(external_id: [nil, '']).count
    if blank_count.positive?
      raise "Cannot make external_identities.external_id NOT NULL: #{blank_count} blank row(s)"
    end

    change_column_null :external_identities, :external_id, false
  end

  def down
    change_column_null :external_identities, :external_id, true
    rename_index :external_identities,
                 'index_external_identities_on_external_resource_and_external_id',
                 'idx_on_external_resource_identificator_ab3aeda95b'
    rename_column :external_identities, :external_id, :identificator
  end
end
