module Admin
  module InfoFetchers
    module OpenLibrary
      module Api
        # Fetches an author record from Open Library by author key / OLID.
        # Docs: https://openlibrary.org/dev/docs/api/authors
        # Endpoint: GET /authors/{OLID}.json
        class AuthorDetailsFetcher < BaseCaller
          def initialize(author_key) # rubocop:disable Lint/MissingSuper
            @author_key = author_key
          end

          def fetch
            olid = self.class.normalize_author_key(author_key)
            return if olid.blank?

            request_data("/authors/#{olid}.json")
          end

          # Accepts "OL1394865A", "/authors/OL1394865A", or full URL-ish paths.
          def self.normalize_author_key(key)
            value = key.to_s.strip
            return if value.blank?

            value = value.delete_prefix(BASE_URL)
            value = value.split('?', 2).first
            value = value.split('#', 2).first
            value = value.delete_suffix('.json')
            value[%r{(?:/authors/)?(OL\d+A)\z}i, 1]&.upcase
          end

          private

          attr_reader :author_key
        end
      end
    end
  end
end
