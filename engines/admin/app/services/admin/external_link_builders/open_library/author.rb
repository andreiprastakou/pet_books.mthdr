# frozen_string_literal: true

module Admin
  module ExternalLinkBuilders
    module OpenLibrary
      # User page for an Open Library author, e.g. https://openlibrary.org/authors/OL1394865A
      class Author < Base
        BASE_URL = 'https://openlibrary.org'

        # Accepts "OL1394865A", "/authors/OL1394865A", or full URL-ish paths.
        def self.normalize_id(identificator)
          Admin::InfoFetchers::OpenLibrary::Api::AuthorDetailsFetcher.normalize_author_key(identificator)
        end

        private

        def build_url(id)
          "#{BASE_URL}/authors/#{id}"
        end

        def normalized_id
          self.class.normalize_id(identificator)
        end
      end
    end
  end
end
