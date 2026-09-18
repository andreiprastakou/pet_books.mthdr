# frozen_string_literal: true

module Admin
  module InfoFetchers
    module Wikipedia
      module Api
        # Generic MediaWiki Action API client for Wikipedia.
        # Docs: https://www.mediawiki.org/wiki/API:Main_page
        # Endpoint: GET https://{lang}.wikipedia.org/w/api.php
        #
        # Example (plain-text intro):
        #   Fetcher.new.fetch(
        #     action: 'query',
        #     prop: 'extracts',
        #     exintro: 1,
        #     explaintext: 1,
        #     titles: 'Tress of the Emerald Sea'
        #   )
        class Fetcher
          API_PATH = '/w/api.php'
          # Wikimedia requires an identifying User-Agent with contact info.
          # See https://meta.wikimedia.org/wiki/User-Agent_policy
          USER_AGENT = ENV.fetch(
            'WIKIPEDIA_USER_AGENT',
            ENV.fetch(
              'WIKIDATA_USER_AGENT',
              ENV.fetch(
                'OPEN_LIBRARY_USER_AGENT',
                'books.mthdr (https://books-mthdr.fly.dev)'
              )
            )
          ).freeze
          RATE_LIMIT_NAME = 'wikipedia'
          # Gateway allows ~200 req/min with a compliant UA; stay well under that.
          RATE_LIMIT_INTERVAL_SECONDS = 0.5
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
          DEFAULT_LANGUAGE = 'en'

          # Runs inside Faraday's retry stack so each attempt (including retries) is spaced.
          class RateLimitMiddleware < Faraday::Middleware
            def on_request(_env)
              Admin::ExternalApiRateLimit.throttle!(
                RATE_LIMIT_NAME,
                min_interval_seconds: RATE_LIMIT_INTERVAL_SECONDS
              )
            end
          end

          def initialize(language: DEFAULT_LANGUAGE)
            @language = language.to_s.strip.presence || DEFAULT_LANGUAGE
          end

          # Calls /w/api.php with the given Action API params.
          # Always requests JSON (formatversion=2).
          def fetch(params = {})
            request_data(default_params.merge(params))
          end

          # Plain-text lead section extract for a page title (or titles joined with "|").
          # Docs: https://www.mediawiki.org/wiki/Extension:TextExtracts
          def fetch_intro(title)
            return if title.blank?

            fetch(
              action: 'query',
              prop: 'extracts',
              exintro: 1,
              explaintext: 1,
              titles: title
            )
          end

          private

          attr_reader :language

          def default_params
            { format: 'json', formatversion: 2 }
          end

          def request_data(params)
            url = build_url(params)
            Bench.log("wikipedia call #{url}") do
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

          def build_url(params = {})
            query = params.compact.to_query
            base = "https://#{language}.wikipedia.org#{API_PATH}"
            query.present? ? "#{base}?#{query}" : base
          end
        end
      end
    end
  end
end
