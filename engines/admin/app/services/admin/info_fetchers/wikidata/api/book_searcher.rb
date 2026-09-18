module Admin
  module InfoFetchers
    module Wikidata
      module Api
        # Searches Wikidata items by a Book's title.
        # Docs: https://www.wikidata.org/wiki/Wikidata:REST_API
        # Endpoint: GET /search/items?q=...&language=en
        class BookSearcher < BaseCaller
          DEFAULT_LANGUAGE = 'en'.freeze
          DEFAULT_LIMIT = 10

          def initialize(book) # rubocop:disable Lint/MissingSuper
            @book = book
          end

          def search(limit: DEFAULT_LIMIT, language: DEFAULT_LANGUAGE)
            title = simplify_query(book.title)
            return [] if title.blank?

            params = {
              q: title,
              language: language,
              limit: limit
            }

            data = request_data('/search/items', params)
            return [] if data.blank?

            data.fetch('results', [])
          end

          private

          attr_reader :book
        end
      end
    end
  end
end
