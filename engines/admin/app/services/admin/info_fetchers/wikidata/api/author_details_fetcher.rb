module Admin
  module InfoFetchers
    module Wikidata
      module Api
        # Fetches a Wikidata author (person) item by Q-ID.
        # Docs: https://www.wikidata.org/wiki/Wikidata:REST_API
        # Endpoint: GET /entities/items/{QID}
        class AuthorDetailsFetcher < BaseCaller
          def initialize(entity_id) # rubocop:disable Lint/MissingSuper
            @entity_id = entity_id
          end

          def fetch
            qid = self.class.normalize_entity_id(entity_id)
            return if qid.blank?

            request_data("/entities/items/#{qid}")
          end

          def self.normalize_entity_id(key)
            BaseCaller.normalize_entity_id(key)
          end

          private

          attr_reader :entity_id
        end
      end
    end
  end
end
