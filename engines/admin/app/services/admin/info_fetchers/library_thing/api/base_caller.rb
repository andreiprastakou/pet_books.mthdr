module Admin
  module InfoFetchers
    module LibraryThing
      module Api
        # Lightweight LibraryThing APIs (thingISBN, thingTitle, …).
        # Docs: https://www.librarything.com/developer/documentation/thingapis
        # Requires LIBRARYTHING_APP_TOKEN from a free LibraryThing developer account.
        class BaseCaller
          include Admin::InfoFetchers::HttpClient

          BASE_URL = 'https://www.librarything.com'.freeze
          USER_AGENT = ENV.fetch(
            'LIBRARYTHING_USER_AGENT',
            ENV.fetch(
              'API_USER_AGENT',
              'books.mthdr (https://books-mthdr.fly.dev)'
            )
          ).freeze
          RATE_LIMIT_NAME = 'library_thing'.freeze
          # LT docs: max 1 request/second for lightweight APIs.
          RATE_LIMIT_INTERVAL_SECONDS = 1.0

          private

          def request_data(method_path, params = {})
            token = app_token
            return log_missing_token if token.blank?

            fetch_xml(build_url(BASE_URL, "/api/#{token}/#{method_path}", params), token)
          rescue Faraday::Error => e
            Rails.logger.error("Failed GET librarything: #{e.class} #{e.message}")
            nil
          end

          def fetch_xml(url, token)
            Bench.log("librarything call #{url.sub(token, '[TOKEN]')}") do
              response = connection.get(url)
              break parse_xml(response.body) if response.success?

              Rails.logger.error("Failed GET librarything: #{response.status}")
              nil
            end
          end

          def log_missing_token
            Rails.logger.error('LIBRARYTHING_APP_TOKEN is not set')
            nil
          end

          def app_token
            ENV['LIBRARYTHING_APP_TOKEN'].presence
          end

          def parse_xml(body)
            return if body.blank?

            Hash.from_xml(body)
          rescue REXML::ParseException, ArgumentError => e
            Rails.logger.error("Failed to parse LibraryThing XML: #{e.class} #{e.message}")
            nil
          end

          def connection
            @connection ||= default_api_connection(accept: 'application/xml, text/xml, */*')
          end
        end
      end
    end
  end
end
