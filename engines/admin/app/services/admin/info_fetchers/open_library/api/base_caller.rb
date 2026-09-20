module Admin
  module InfoFetchers
    module OpenLibrary
      module Api
        class BaseCaller
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

          # Runs inside Faraday's retry stack so each attempt (including retries) is spaced.
          class RateLimitMiddleware < Faraday::Middleware
            def on_request(_env)
              Admin::ExternalApiRateLimit.throttle!(
                RATE_LIMIT_NAME,
                min_interval_seconds: RATE_LIMIT_INTERVAL_SECONDS
              )
            end
          end

          private

          def request_data(path, params = {})
            url = build_url(path, params)
            Bench.log("openlibrary call #{url}") do
              response = connection.get(url)
              break JSON.parse(response.body) if response.success?

              Rails.logger.error("Failed GET #{url}: #{response.status}")
              nil
            end
          rescue Faraday::Error => e
            Rails.logger.error("Failed GET #{url}: #{e.class} #{e.message}")
            nil
          end

          def connection
            @connection ||= Faraday.new { |f| configure_connection(f) }
          end

          def configure_connection(faraday)
            faraday.use RateLimitMiddleware
            faraday.request :retry, retry_options
            faraday.headers['User-Agent'] = USER_AGENT
            faraday.headers['Accept'] = 'application/json'
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

          # Downcase and strip punctuation/diacritics while keeping letters (any script) and numbers.
          def simplify_query(text)
            text.to_s
                .unicode_normalize(:nfkd)
                .gsub(/\p{M}/, '')
                .downcase
                .gsub(/[^\p{L}\p{N}\s]/, ' ')
                .squeeze(' ')
                .strip
          end
        end
      end
    end
  end
end
