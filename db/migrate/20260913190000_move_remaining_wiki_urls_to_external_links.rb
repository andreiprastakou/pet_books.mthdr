# frozen_string_literal: true

class MoveRemainingWikiUrlsToExternalLinks < ActiveRecord::Migration[8.1]
  class SeriesStub < ApplicationRecord
    self.table_name = 'series'
  end

  class CollectionStub < ApplicationRecord
    self.table_name = 'collections'
  end

  class PublicListStub < ApplicationRecord
    self.table_name = 'public_lists'
  end

  class PublicListTypeStub < ApplicationRecord
    self.table_name = 'public_list_types'
  end

  class ExternalLinkStub < ApplicationRecord
    self.table_name = 'external_links'
  end

  WIKIPEDIA = 'wikipedia'

  def up
    migrate_wiki_urls(SeriesStub, 'Series')
    migrate_wiki_urls(CollectionStub, 'Collection')
    migrate_wiki_urls(PublicListStub, 'PublicList')
    migrate_wiki_urls(PublicListTypeStub, 'PublicListType')

    remove_column :series, :wiki_url
    remove_column :collections, :wiki_url
    remove_column :public_lists, :wiki_url
    remove_column :public_list_types, :wiki_url
  end

  def down
    add_column :series, :wiki_url, :string
    add_column :collections, :wiki_url, :string
    add_column :public_lists, :wiki_url, :string
    add_column :public_list_types, :wiki_url, :string

    backfill_wiki_urls(SeriesStub, 'Series')
    backfill_wiki_urls(CollectionStub, 'Collection')
    backfill_wiki_urls(PublicListStub, 'PublicList')
    backfill_wiki_urls(PublicListTypeStub, 'PublicListType')
  end

  private

  def migrate_wiki_urls(stub_class, owner_type)
    stub_class.where.not(wiki_url: [nil, '']).find_each do |record|
      ExternalLinkStub.where(
        owner_type: owner_type,
        owner_id: record.id,
        external_resource: WIKIPEDIA,
        url: record.wiki_url
      ).first_or_create!
    end
  end

  def backfill_wiki_urls(stub_class, owner_type)
    ExternalLinkStub.where(owner_type: owner_type, external_resource: WIKIPEDIA).find_each do |link|
      stub_class.where(id: link.owner_id, wiki_url: nil).update_all(wiki_url: link.url)
    end
  end
end
