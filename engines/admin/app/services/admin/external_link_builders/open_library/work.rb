# frozen_string_literal: true

module Admin
  module ExternalLinkBuilders
    module OpenLibrary
      # User page for an Open Library work, e.g. https://openlibrary.org/works/OL42413123W
      class Work < Base
        BASE_URL = 'https://openlibrary.org'

        private

        def build_url(id)
          "#{BASE_URL}/works/#{id}"
        end

        def normalized_id
          Admin::InfoFetchers::OpenLibrary::Api::BookDetailsFetcher.normalize_work_key(identificator)
        end
      end
    end
  end
end
