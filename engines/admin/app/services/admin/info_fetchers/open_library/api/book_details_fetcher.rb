module Admin
  module InfoFetchers
    module OpenLibrary
      module Api
        # Fetches a work record from Open Library by work key / OLID.
        class BookDetailsFetcher < EntityDetailsFetcher
          configure_resource :works
        end
      end
    end
  end
end
