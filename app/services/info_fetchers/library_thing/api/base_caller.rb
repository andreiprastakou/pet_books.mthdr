module InfoFetchers
  module LibraryThing
    module Api
      # Lightweight LibraryThing APIs (thingISBN, thingTitle, …).
      # Docs: https://www.librarything.com/developer/documentation/thingapis
      # Requires LIBRARYTHING_APP_TOKEN from a free LibraryThing developer account.
      class BaseCaller
        BASE_URL = 'https://www.librarything.com'
        USER_AGENT = ENV.fetch(
          'LIBRARYTHING_USER_AGENT',
          ENV.fetch(
            'OPEN_LIBRARY_USER_AGENT',
            'books.mthdr (https://books-mthdr.fly.dev)'
          )
        ).freeze
        RATE_LIMIT_NAME = 'library_thing'
        # LT docs: max 1 request/second for lightweight APIs.
        RATE_LIMIT_INTERVAL_SECONDS = 1.0
        OPEN_TIMEOUT = 10
        TIMEOUT = 30
        MAX_RETRIES = 3

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
          if token.blank?
            Rails.logger.error('LIBRARYTHING_APP_TOKEN is not set')
            return
          end

          url = build_url("/api/#{token}/#{method_path}", params)
          Bench.log("librarything call #{url.sub(token, '[TOKEN]')}") do
            response = connection.get(url)
            break parse_xml(response.body) if response.success?

            Rails.logger.error("Failed GET librarything: #{response.status}")
            nil
          end
        rescue Faraday::Error => e
          Rails.logger.error("Failed GET librarything: #{e.class} #{e.message}")
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
            f.headers['Accept'] = 'application/xml, text/xml, */*'
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
