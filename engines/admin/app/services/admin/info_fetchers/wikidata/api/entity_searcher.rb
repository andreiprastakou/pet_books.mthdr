module Admin
  module InfoFetchers
    module Wikidata
      module Api
        # Shared Wikidata item search by free-text query.
        # Docs: https://www.wikidata.org/wiki/Wikidata:REST_API
        # Endpoint: GET /search/items?q=...&language=en
        class EntitySearcher < BaseCaller
          DEFAULT_LANGUAGE = 'en'.freeze
          DEFAULT_LIMIT = 10

          def initialize(query_source) # rubocop:disable Lint/MissingSuper
            @query_source = query_source
          end

          def search(limit: DEFAULT_LIMIT, language: DEFAULT_LANGUAGE)
            search_by_query(query_text, limit: limit, language: language)
          end

          private

          attr_reader :query_source

          def query_text
            raise NotImplementedError
          end

          def search_by_query(query_text, limit: DEFAULT_LIMIT, language: DEFAULT_LANGUAGE)
            query = simplify_query(query_text)
            return [] if query.blank?

            data = request_data('/search/items', q: query, language: language, limit: limit)
            return [] if data.blank?

            data.fetch('results', [])
          end
        end
      end
    end
  end
end
