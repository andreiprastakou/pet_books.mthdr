module Admin
  module InfoFetchers
    module OpenLibrary
      module Api
        class BaseCaller
          include Admin::InfoFetchers::HttpClient
          include Admin::InfoFetchers::QuerySimplifier

          BASE_URL = 'https://openlibrary.org'.freeze
          # Identified clients get 3 req/s (vs 1 req/s anonymous). Include a real contact email via ENV.
          # See https://openlibrary.org/developers/api
          USER_AGENT = ENV.fetch(
            'OPEN_LIBRARY_USER_AGENT',
            ENV.fetch(
              'API_USER_AGENT',
              'books.mthdr (https://books-mthdr.fly.dev)'
            )
          ).freeze
          RATE_LIMIT_NAME = 'open_library'.freeze
          RATE_LIMIT_INTERVAL_SECONDS = 1.0 / 3

          private

          def request_data(path, params = {})
            request_json(build_url(BASE_URL, path, params), log_label: 'openlibrary call')
          end

          def connection
            @connection ||= default_api_connection
          end
        end
      end
    end
  end
end
