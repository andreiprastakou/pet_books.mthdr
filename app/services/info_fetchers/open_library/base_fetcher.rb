module InfoFetchers
  module OpenLibrary
    class BaseFetcher
      BASE_URL = 'https://openlibrary.org'
      # Identified clients get 3 req/s (vs 1 req/s anonymous). Include a real contact email via ENV.
      # See https://openlibrary.org/developers/api
      USER_AGENT = ENV.fetch(
        'OPEN_LIBRARY_USER_AGENT',
        'books.mthdr (https://books-mthdr.fly.dev)'
      ).freeze
      OPEN_TIMEOUT = 10
      TIMEOUT = 30
      MAX_RETRIES = 3

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
        @connection ||= Faraday.new do |f|
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
