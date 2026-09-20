module Admin
  module InfoFetchers
    module Wikipedia
      class BookSyncer
        def initialize(book)
          @book = book.is_a?(Admin::Book) ? book : Admin::Book.cast(book)
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
          raise "No wikipedia link for book #{book.id}" if book.wiki_url.blank?
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
          # Admin::InfoFetchers::Wikipedia::VariantsFetcher.new.fetch_variants(name, locale)
          { locale => name }
        end

        def fetch_base_page_parts
          name, locale = Admin::InfoFetchers::Wikipedia::UrlParser.extract_base_name_and_locale(book.wiki_url)
          raise "Can't extract base name and locale from #{book.wiki_url}" if name.blank? || locale.blank?

          [name, locale]
        end

        def sync_page_stats(links)
          links.each { |wiki_link| ViewsSync.update_link_views!(wiki_link) }
        end
      end
    end
  end
end
