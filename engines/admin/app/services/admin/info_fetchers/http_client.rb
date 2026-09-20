# frozen_string_literal: true

module Admin
  module InfoFetchers
    # Shared Faraday connection setup and JSON GET helper for external info APIs.
    module HttpClient
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

      private

      def request_json(url, log_label:)
        Bench.log("#{log_label} #{url}") do
          response = connection.get(url)
          break JSON.parse(response.body) if response.success?

          Rails.logger.error("Failed GET #{url}: #{response.status}")
          nil
        end
      rescue Faraday::Error => e
        Rails.logger.error("Failed GET #{url}: #{e.class} #{e.message}")
        nil
      end

      def configure_connection(faraday, user_agent:, accept:, rate_limit_name:, rate_limit_interval:)
        faraday.use RateLimitMiddleware, name: rate_limit_name, min_interval_seconds: rate_limit_interval
        faraday.request :retry, retry_options
        faraday.headers['User-Agent'] = user_agent
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

      def build_url(base_url, path, params = {})
        query = params.compact.to_query
        query.present? ? "#{base_url}#{path}?#{query}" : "#{base_url}#{path}"
      end

      def build_connection(user_agent:, accept:, rate_limit_name:, rate_limit_interval:)
        Faraday.new do |f|
          configure_connection(
            f,
            user_agent: user_agent,
            accept: accept,
            rate_limit_name: rate_limit_name,
            rate_limit_interval: rate_limit_interval
          )
        end
      end

      def default_api_connection(accept: 'application/json')
        build_connection(
          user_agent: self.class::USER_AGENT,
          accept: accept,
          rate_limit_name: self.class::RATE_LIMIT_NAME,
          rate_limit_interval: self.class::RATE_LIMIT_INTERVAL_SECONDS
        )
      end
    end
  end
end
