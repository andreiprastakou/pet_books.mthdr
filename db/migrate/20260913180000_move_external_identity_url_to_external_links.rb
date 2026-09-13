# frozen_string_literal: true

class MoveExternalIdentityUrlToExternalLinks < ActiveRecord::Migration[8.1]
  class ExternalIdentityStub < ApplicationRecord
    self.table_name = 'external_identities'
  end

  class ExternalLinkStub < ApplicationRecord
    self.table_name = 'external_links'
  end

  RESOURCE_NAMES = {
    1 => 'open_library',
    2 => 'wikidata',
    3 => 'librarything',
    4 => 'goodreads'
  }.freeze

  def up
    add_reference :external_identities, :external_link, null: true, foreign_key: { on_delete: :nullify }

    ExternalIdentityStub.where.not(url: [nil, '']).find_each do |identity|
      name = RESOURCE_NAMES.fetch(identity.external_resource)
      link = ExternalLinkStub.where(
        entity_type: identity.owner_type,
        entity_id: identity.owner_id,
        name: name,
        url: identity.url
      ).first_or_create!

      identity.update!(external_link_id: link.id)
    end

    remove_column :external_identities, :url
  end

  def down
    add_column :external_identities, :url, :string

    ExternalIdentityStub.where.not(external_link_id: nil).find_each do |identity|
      link = ExternalLinkStub.find_by(id: identity.external_link_id)
      next if link.blank?

      identity.update!(url: link.url)
    end

    remove_reference :external_identities, :external_link, foreign_key: true
  end
end
