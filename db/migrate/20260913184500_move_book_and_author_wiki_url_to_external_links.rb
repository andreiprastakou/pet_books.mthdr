# frozen_string_literal: true

class MoveBookAndAuthorWikiUrlToExternalLinks < ActiveRecord::Migration[8.1]
  class BookStub < ApplicationRecord
    self.table_name = 'books'
  end

  class AuthorStub < ApplicationRecord
    self.table_name = 'authors'
  end

  class ExternalLinkStub < ApplicationRecord
    self.table_name = 'external_links'
  end

  WIKIPEDIA = 'wikipedia'

  def up
    migrate_wiki_urls(BookStub, 'Book')
    migrate_wiki_urls(AuthorStub, 'Author')

    remove_column :books, :wiki_url
    remove_column :authors, :wiki_url
  end

  def down
    add_column :books, :wiki_url, :string
    add_column :authors, :wiki_url, :string

    backfill_wiki_urls(BookStub, 'Book')
    backfill_wiki_urls(AuthorStub, 'Author')
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
