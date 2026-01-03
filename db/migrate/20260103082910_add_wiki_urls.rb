class AddWikiUrls < ActiveRecord::Migration[8.1]
  def change
    add_column :public_list_types, :wiki_url, :string
    add_column :public_lists, :wiki_url, :string
    add_column :series, :wiki_url, :string
    add_column :collections, :wiki_url, :string

    rename_column :authors, :reference, :wiki_url
  end
end
