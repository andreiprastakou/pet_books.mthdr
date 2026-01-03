class MakeWikiLinkUrlNotNull < ActiveRecord::Migration[8.1]
  def change
    change_column_null :wiki_links, :url, false
  end
end
