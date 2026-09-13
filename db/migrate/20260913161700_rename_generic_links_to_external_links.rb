class RenameGenericLinksToExternalLinks < ActiveRecord::Migration[8.1]
  def change
    rename_table :generic_links, :external_links
  end
end
