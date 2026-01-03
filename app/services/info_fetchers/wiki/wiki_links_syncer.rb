module InfoFetchers
  module Wiki
    class WikiLinksSyncer
      def initialize(wiki_link)
        @wiki_link = wiki_link
      end

      def sync!
        views, views_last_month = fetch_views(wiki_link)
        return if views.nil? || views_last_month.nil?

        update_wiki_link(views, views_last_month)

        update_entity
      end

      private

      attr_reader :wiki_link

      def update_wiki_link(views, views_last_month)
        wiki_link.views ||= 0
        wiki_link.views += views - (wiki_link.views_last_month || 0)
        wiki_link.update!(views_last_month: views_last_month, views_synced_at: Time.now.utc)
      end

      def fetch_views(wiki_link)
        InfoFetchers::Wiki::ViewsFetcher
          .new
          .fetch(wiki_link.name, wiki_link.locale, last_synced_at: wiki_link.views_synced_at)
      end

      def update_entity
        return unless wiki_link.entity.is_a?(Book)

        wiki_link.entity.update!(wiki_popularity: wiki_link.entity.wiki_links_sum_views)
      end
    end
  end
end
