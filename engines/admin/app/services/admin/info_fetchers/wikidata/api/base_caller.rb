module Admin
  module InfoFetchers
    module Wikidata
      module Api
        class BaseCaller
          include Admin::InfoFetchers::HttpClient
          include Admin::InfoFetchers::QuerySimplifier

          BASE_URL = 'https://www.wikidata.org/w/rest.php/wikibase/v1'.freeze
          # Wikimedia requires an identifying User-Agent with contact info.
          # See https://meta.wikimedia.org/wiki/User-Agent_policy
          USER_AGENT = ENV.fetch(
            'WIKIDATA_USER_AGENT',
            ENV.fetch(
              'API_USER_AGENT',
              'books.mthdr (https://books-mthdr.fly.dev)'
            )
          ).freeze
          RATE_LIMIT_NAME = 'wikidata'.freeze
          RATE_LIMIT_INTERVAL_SECONDS = 1.0

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

          def request_data(path, params = {})
            request_json(build_url(BASE_URL, path, params), log_label: 'wikidata call')
          end

          def connection
            @connection ||= default_api_connection
          end
        end
      end
    end
  end
end
