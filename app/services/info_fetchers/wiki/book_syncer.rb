module InfoFetchers
  module Wiki
    class BookSyncer
      def initialize(book)
        @book = book
      end

      def sync!
        ensure_valid_context

        book.wiki_links |= initialize_links
        sync_page_stats(book.wiki_links)
        book.update!(wiki_popularity: book.wiki_links_sum_views)
      end

      private

      attr_reader :book

      def ensure_valid_context
        raise "No wiki_url for book #{book.id}" if book.wiki_url.blank?
      end

      def initialize_links
        variants = fetch_variants
        variants.map do |locale, name|
          next if book.wiki_links.find { |link| link.locale == locale && link.name == name }

          WikiLink.build_from_parts(locale: locale, name: name)
        end.compact
      end

      def fetch_variants
        name, locale = fetch_base_page_parts
        # InfoFetchers::Wiki::VariantsFetcher.new.fetch_variants(name, locale)
        { locale => name }
      end

      def fetch_base_page_parts
        name, locale = InfoFetchers::Wiki::UrlParser.extract_base_name_and_locale(book.wiki_url)
        raise "Can't extract base name and locale from #{book.wiki_url}" if name.blank? || locale.blank?

        [name, locale]
      end

      def sync_page_stats(links)
        links.each do |wiki_link|
          views, views_last_month = fetch_views(wiki_link)
          next if views.nil? || views_last_month.nil?

          wiki_link.views ||= 0
          wiki_link.views += views - (wiki_link.views_last_month || 0)
          wiki_link.update!(views_last_month: views_last_month, views_synced_at: Time.now.utc)
        end
      end

      def fetch_views(wiki_link)
        InfoFetchers::Wiki::ViewsFetcher
          .new
          .fetch(wiki_link.name, wiki_link.locale, last_synced_at: wiki_link.views_synced_at)
      end
    end
  end
end
