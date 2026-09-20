module Admin
  module InfoFetchers
    module Wikipedia
      class WikiLinksSyncer
        def initialize(wiki_link)
          @wiki_link = wiki_link
        end

        def sync!
          return unless ViewsSync.update_link_views!(wiki_link)

          update_entity
        end

        private

        attr_reader :wiki_link

        def update_entity
          return unless wiki_link.entity.is_a?(Book)

          book = Admin::Book.cast(wiki_link.entity)
          book.update!(wiki_popularity: book.wiki_links_sum_views)
        end
      end
    end
  end
end
