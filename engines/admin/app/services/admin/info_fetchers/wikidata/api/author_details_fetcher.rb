module Admin
  module InfoFetchers
    module Wikidata
      module Api
        # Fetches a Wikidata author (person) item by Q-ID.
        # Docs: https://www.wikidata.org/wiki/Wikidata:REST_API
        # Endpoint: GET /entities/items/{QID}
        class AuthorDetailsFetcher < EntityDetailsFetcher
        end
      end
    end
  end
end
