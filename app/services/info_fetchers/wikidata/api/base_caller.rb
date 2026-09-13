module InfoFetchers
  module Wikidata
    module Api
      class BaseCaller
        BASE_URL = 'https://www.wikidata.org/w/rest.php/wikibase/v1'
        # Wikimedia requires an identifying User-Agent with contact info.
        # See https://meta.wikimedia.org/wiki/User-Agent_policy
        USER_AGENT = ENV.fetch(
          'WIKIDATA_USER_AGENT',
          ENV.fetch(
            'OPEN_LIBRARY_USER_AGENT',
            'books.mthdr (https://books-mthdr.fly.dev)'
          )
        ).freeze
        RATE_LIMIT_NAME = 'wikidata'
        RATE_LIMIT_INTERVAL_SECONDS = 1.0
        OPEN_TIMEOUT = 10
        TIMEOUT = 30
        MAX_RETRIES = 3

        # Runs inside Faraday's retry stack so each attempt (including retries) is spaced.
        class RateLimitMiddleware < Faraday::Middleware
          def on_request(_env)
            ExternalApiRateLimit.throttle!(
              RATE_LIMIT_NAME,
              min_interval_seconds: RATE_LIMIT_INTERVAL_SECONDS
            )
          end
        end

        private

        def request_data(path, params = {})
          url = build_url(path, params)
          Bench.log("wikidata call #{url}") do
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
          @connection ||= Faraday.new do |f|
            f.use RateLimitMiddleware
            f.request :retry, {
              max: MAX_RETRIES,
              interval: 0.5,
              interval_randomness: 0.5,
              backoff_factor: 2,
              exceptions: [
                Faraday::ConnectionFailed,
                Faraday::TimeoutError,
                Faraday::RetriableResponse,
                Errno::ECONNRESET,
                Errno::ETIMEDOUT
              ]
            }
            f.headers['User-Agent'] = USER_AGENT
            f.headers['Accept'] = 'application/json'
            f.options.open_timeout = OPEN_TIMEOUT
            f.options.timeout = TIMEOUT
            f.adapter Faraday.default_adapter
          end
        end

        def build_url(path, params = {})
          query = params.compact.to_query
          query.present? ? "#{BASE_URL}#{path}?#{query}" : "#{BASE_URL}#{path}"
        end
      end
    end
  end
end
