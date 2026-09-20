# frozen_string_literal: true

module Admin
  module InfoFetchers
    module Wikidata
      module Api
        # Fetches works authored by a Wikidata person via SPARQL (P50).
        # Docs: https://www.wikidata.org/wiki/Wikidata:SPARQL_query_service
        # Endpoint: POST https://query.wikidata.org/sparql
        class AuthorWorksFetcher < BaseCaller
          SPARQL_URL = 'https://query.wikidata.org/sparql'
          SPARQL_TIMEOUT = 60
          PAGE_SIZE = 100
          MAX_ATTEMPTS = 3
          RETRY_COOLDOWN_RANGE = 1.0..3.0
          # Keep single works / story collections; drop editions, parts, and series.
          # Q3331189 = version, edition or translation (covers audiobook edition, bitext, etc.)
          # Q88392887 = part of a work
          # Q277759 = book series
          # Q1667921 = novel series
          # P629 = edition or translation of
          EXCLUDED_TYPES = %w[Q3331189 Q88392887 Q277759 Q1667921].freeze

          def initialize(entity_id) # rubocop:disable Lint/MissingSuper
            @entity_id = entity_id
          end

          def fetch
            qid = BaseCaller.normalize_entity_id(entity_id)
            return if qid.blank?

            rows = fetch_all_pages(qid)
            return unless rows

            AuthorWorksNormalizer.merge_duplicate_works(rows)
          end

          private

          attr_reader :entity_id

          def fetch_all_pages(qid)
            offset = 0
            rows = []

            loop do
              page = fetch_page(qid, offset)
              return unless page

              rows.concat(page)
              break if page.size < PAGE_SIZE

              offset += PAGE_SIZE
            end

            rows
          end

          def fetch_page(qid, offset)
            data = request_sparql_data(query_for(qid, limit: PAGE_SIZE, offset: offset))
            return unless data

            bindings = data.dig('results', 'bindings')
            return unless bindings.is_a?(Array)

            bindings.filter_map { |binding| AuthorWorksNormalizer.normalize_binding(binding) }
          end

          def query_for(qid, limit: PAGE_SIZE, offset: 0)
            AuthorWorksSparql.query(
              qid: qid,
              excluded_types: EXCLUDED_TYPES,
              limit: limit,
              offset: offset
            )
          end

          def request_sparql_data(query)
            with_retries { perform_sparql_request(query) }
          end

          def with_retries
            attempts = 0

            loop do
              attempts += 1
              result = yield
              return result unless result.nil?
              return if attempts >= MAX_ATTEMPTS

              sleep_before_retry(attempts)
            end
          end

          def sleep_before_retry(attempts)
            cooldown = rand(RETRY_COOLDOWN_RANGE)
            Rails.logger.warn(
              "Wikidata SPARQL request failed; retry #{attempts}/#{MAX_ATTEMPTS - 1} after #{cooldown.round(2)}s"
            )
            sleep(cooldown)
          end

          def perform_sparql_request(query)
            Bench.log("wikidata sparql #{SPARQL_URL}") do
              response = post_sparql(query)
              break JSON.parse(response.body) if response.success?

              Rails.logger.error("Failed POST #{SPARQL_URL}: #{response.status}")
              nil
            end
          rescue Faraday::Error => e
            Rails.logger.error("Failed POST #{SPARQL_URL}: #{e.class} #{e.message}")
            nil
          end

          def post_sparql(query)
            sparql_connection.post(SPARQL_URL) do |req|
              req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
              req.body = { query: query, format: 'json' }.to_query
            end
          end

          def sparql_connection
            @sparql_connection ||= begin
              conn = default_api_connection(accept: 'application/sparql-results+json')
              conn.options.timeout = SPARQL_TIMEOUT
              conn
            end
          end
        end
      end
    end
  end
end
