module Admin
  module InfoFetchers
    module OpenLibrary
      module Api
        # Searches Open Library's Search API for works matching a Book's title and authors.
        # Docs: https://openlibrary.org/dev/docs/api/search
        # Limits: 1 req/s anonymous, 3 req/s with identifying User-Agent (see BaseCaller).
        class BookSearcher < BaseCaller
          DEFAULT_FIELDS = %w[
            key
            title
            author_name
            author_key
            first_publish_year
          ].freeze
          DEFAULT_LIMIT = 10

          def initialize(book)
            @book = book
          end

          def search(limit: DEFAULT_LIMIT, fields: DEFAULT_FIELDS)
            title = simplify_query(book.title)
            return [] if title.blank?

            params = {
              title: title,
              fields: fields.join(','),
              limit: limit
            }
            authors = simplified_author_names
            params[:author] = authors.join(' ') if authors.any?

            data = request_data('/search.json', params)
            return [] if data.blank?

            data.fetch('docs', [])
          end

          private

          attr_reader :book

          def simplified_author_names
            book.authors.filter_map { |author| simplify_query(author.fullname).presence }
          end
        end
      end
    end
  end
end
