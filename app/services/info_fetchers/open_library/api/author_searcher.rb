module InfoFetchers
  module OpenLibrary
    module Api
      # Searches Open Library's Authors Search API by author name.
      # Docs: https://openlibrary.org/dev/docs/api/authors
      # Endpoint: GET /search/authors.json?q=...
      # Limits: 1 req/s anonymous, 3 req/s with identifying User-Agent (see BaseCaller).
      class AuthorSearcher < BaseCaller
        DEFAULT_LIMIT = 10

        def initialize(author)
          @author = author
        end

        def search(limit: DEFAULT_LIMIT)
          name = simplify_query(author.fullname)
          return [] if name.blank?

          params = {
            q: name,
            limit: limit
          }

          data = request_data('/search/authors.json', params)
          return [] if data.blank?

          data.fetch('docs', [])
        end

        private

        attr_reader :author
      end
    end
  end
end
