module Admin
  module InfoFetchers
    module OpenLibrary
      module Api
        # Fetches a work record from Open Library by work key / OLID.
        # Docs: https://openlibrary.org/developers/api (Work & Edition APIs)
        # Endpoint: GET /works/{OLID}.json
        class BookDetailsFetcher < BaseCaller
          def initialize(work_key)
            @work_key = work_key
          end

          def fetch
            olid = self.class.normalize_work_key(work_key)
            return if olid.blank?

            request_data("/works/#{olid}.json")
          end

          # Accepts "OL27448W", "/works/OL27448W", or full URL-ish paths.
          def self.normalize_work_key(key)
            value = key.to_s.strip
            return if value.blank?

            value = value.delete_prefix(BASE_URL)
            value = value.split('?', 2).first
            value = value.split('#', 2).first
            value = value.delete_suffix('.json')
            value[%r{(?:/works/)?(OL\d+W)\z}i, 1]&.upcase
          end

          private

          attr_reader :work_key
        end
      end
    end
  end
end
