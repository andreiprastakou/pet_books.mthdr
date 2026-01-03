class ChangeWikiPageStatsToWikiLinks < ActiveRecord::Migration[8.1]
  class WikiLinkStub < ApplicationRecord
    self.table_name = 'wiki_links'
  end

  def change
    rename_table :wiki_page_stats, :wiki_links
    add_column :wiki_links, :url, :string
    WikiLinkStub.find_each do |record|
      record.update!(url: "https://#{record.locale}.wikipedia.org/wiki/#{URI.encode_uri_component(record.name)}")
    end
  end
end
