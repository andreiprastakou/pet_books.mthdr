module Admin
  module InfoFetchers
    module LibraryThing
      module Api
        # Lightweight LibraryThing APIs (thingISBN, thingTitle, …).
        # Docs: https://www.librarything.com/developer/documentation/thingapis
        # Requires LIBRARYTHING_APP_TOKEN from a free LibraryThing developer account.
        class BaseCaller
          BASE_URL = 'https://www.librarything.com'.freeze
          USER_AGENT = ENV.fetch(
            'LIBRARYTHING_USER_AGENT',
            ENV.fetch(
              'OPEN_LIBRARY_USER_AGENT',
              'books.mthdr (https://books-mthdr.fly.dev)'
            )
          ).freeze
          RATE_LIMIT_NAME = 'library_thing'.freeze
          # LT docs: max 1 request/second for lightweight APIs.
          RATE_LIMIT_INTERVAL_SECONDS = 1.0
          OPEN_TIMEOUT = 10
          TIMEOUT = 30
          MAX_RETRIES = 3
          RETRY_EXCEPTIONS = [
            Faraday::ConnectionFailed,
            Faraday::TimeoutError,
            Faraday::RetriableResponse,
            Errno::ECONNRESET,
            Errno::ETIMEDOUT
          ].freeze

          class RateLimitMiddleware < Faraday::Middleware
            def on_request(_env)
              Admin::ExternalApiRateLimit.throttle!(
                RATE_LIMIT_NAME,
                min_interval_seconds: RATE_LIMIT_INTERVAL_SECONDS
              )
            end
          end

          private

          def request_data(method_path, params = {})
            token = app_token
            return log_missing_token if token.blank?

            fetch_xml(build_url("/api/#{token}/#{method_path}", params), token)
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
            @connection ||= Faraday.new { |f| configure_connection(f, accept: 'application/xml, text/xml, */*') }
          end

          def configure_connection(faraday, accept:)
            faraday.use RateLimitMiddleware
            faraday.request :retry, retry_options
            faraday.headers['User-Agent'] = USER_AGENT
            faraday.headers['Accept'] = accept
            faraday.options.open_timeout = OPEN_TIMEOUT
            faraday.options.timeout = TIMEOUT
            faraday.adapter Faraday.default_adapter
          end

          def retry_options
            {
              max: MAX_RETRIES,
              interval: 0.5,
              interval_randomness: 0.5,
              backoff_factor: 2,
              exceptions: RETRY_EXCEPTIONS
            }
          end

          def build_url(path, params = {})
            query = params.compact.to_query
            query.present? ? "#{BASE_URL}#{path}?#{query}" : "#{BASE_URL}#{path}"
          end
        end
      end
    end
  end
end
