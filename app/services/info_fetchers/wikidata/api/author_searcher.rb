module InfoFetchers
  module Wikidata
    module Api
      # Searches Wikidata items by an Author's name.
      # Docs: https://www.wikidata.org/wiki/Wikidata:REST_API
      # Endpoint: GET /search/items?q=...&language=en
      class AuthorSearcher < BaseCaller
        DEFAULT_LANGUAGE = 'en'
        DEFAULT_LIMIT = 10

        def initialize(author)
          @author = author
        end

        def search(limit: DEFAULT_LIMIT, language: DEFAULT_LANGUAGE)
          name = simplify_query(author.fullname)
          return [] if name.blank?

          params = {
            q: name,
            language: language,
            limit: limit
          }

          data = request_data('/search/items', params)
          return [] if data.blank?

          data.fetch('results', [])
        end

        private

        attr_reader :author
      end
    end
  end
end
