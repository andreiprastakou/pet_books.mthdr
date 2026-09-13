module InfoFetchers
  module Wikidata
    module Api
      # Fetches a Wikidata item by Q-ID.
      # Docs: https://www.wikidata.org/wiki/Wikidata:REST_API
      # Endpoint: GET /entities/items/{QID}
      class BookDetailsFetcher < BaseCaller
        def initialize(entity_id)
          @entity_id = entity_id
        end

        def fetch
          qid = self.class.normalize_entity_id(entity_id)
          return if qid.blank?

          request_data("/entities/items/#{qid}")
        end

        # Accepts "Q42", "/wiki/Q42", or full URL-ish paths.
        def self.normalize_entity_id(key)
          value = key.to_s.strip
          return if value.blank?

          value = value.delete_prefix(BASE_URL)
          value = value.delete_prefix('https://www.wikidata.org')
          value = value.delete_prefix('http://www.wikidata.org')
          value = value.split('?', 2).first
          value = value.split('#', 2).first
          value[%r{(?:/wiki/|/entities/items/)?(Q\d+)\z}i, 1]&.upcase
        end

        private

        attr_reader :entity_id
      end
    end
  end
end
