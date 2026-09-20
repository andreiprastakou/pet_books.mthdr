module Admin
  module InfoFetchers
    module OpenLibrary
      module Api
        # Fetches an author record from Open Library by author key / OLID.
        class AuthorDetailsFetcher < EntityDetailsFetcher
          configure_resource :authors
        end
      end
    end
  end
end
