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
          include Admin::InfoFetchers::HttpClient

          API_PATH = '/w/api.php'
          # Wikimedia requires an identifying User-Agent with contact info.
          # See https://meta.wikimedia.org/wiki/User-Agent_policy
          USER_AGENT = ENV.fetch(
            'WIKIPEDIA_USER_AGENT',
            ENV.fetch(
              'WIKIDATA_USER_AGENT',
              ENV.fetch(
                'API_USER_AGENT',
                'books.mthdr (https://books-mthdr.fly.dev)'
              )
            )
          ).freeze
          RATE_LIMIT_NAME = 'wikipedia'
          # Gateway allows ~200 req/min with a compliant UA; stay well under that.
          RATE_LIMIT_INTERVAL_SECONDS = 0.5
          DEFAULT_LANGUAGE = 'en'

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
            request_json(build_api_url(params), log_label: 'wikipedia call')
          end

          def connection
            @connection ||= default_api_connection
          end

          def build_api_url(params = {})
            query = params.compact.to_query
            base = "https://#{language}.wikipedia.org#{API_PATH}"
            query.present? ? "#{base}?#{query}" : base
          end
        end
      end
    end
  end
end
