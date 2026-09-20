# frozen_string_literal: true

module Admin
  module InfoFetchers
    module Wikipedia
      # Shared Wikipedia page-view fetch + cumulative update for wiki links.
      module ViewsSync
        module_function

        def update_link_views!(wiki_link)
          views, views_last_month = fetch_views(wiki_link)
          return if views.nil? || views_last_month.nil?

          wiki_link.views ||= 0
          wiki_link.views += views - (wiki_link.views_last_month || 0)
          wiki_link.update!(views_last_month: views_last_month, views_synced_at: Time.now.utc)
          true
        end

        def fetch_views(wiki_link)
          ViewsFetcher
            .new
            .fetch(wiki_link.name, wiki_link.locale, last_synced_at: wiki_link.views_synced_at)
        end
      end
    end
  end
end
