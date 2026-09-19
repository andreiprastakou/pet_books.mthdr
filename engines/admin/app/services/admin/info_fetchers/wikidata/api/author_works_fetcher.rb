# frozen_string_literal: true

module Admin
  module InfoFetchers
    module Wikidata
      module Api
        # Fetches works authored by a Wikidata person via SPARQL (P50).
        # Docs: https://www.wikidata.org/wiki/Wikidata:SPARQL_query_service
        # Endpoint: POST https://query.wikidata.org/sparql
        class AuthorWorksFetcher < BaseCaller
          SPARQL_URL = 'https://query.wikidata.org/sparql'.freeze
          SPARQL_TIMEOUT = 60
          WORK_URI_PREFIX = 'http://www.wikidata.org/entity/'
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

            merge_duplicate_works(rows)
          end

          private

          attr_reader :entity_id

          def fetch_all_pages(qid)
            offset = 0
            rows = []

            loop do
              data = request_sparql_data(query_for(qid, limit: PAGE_SIZE, offset: offset))
              return unless data

              bindings = data.dig('results', 'bindings')
              return unless bindings.is_a?(Array)

              rows.concat(bindings.filter_map { |binding| normalize_binding(binding) })
              break if bindings.size < PAGE_SIZE

              offset += PAGE_SIZE
            end

            rows
          end

          def query_for(qid, limit: PAGE_SIZE, offset: 0)
            excluded = EXCLUDED_TYPES.map { |type| "wd:#{type}" }.join(' ')

            <<~SPARQL
              SELECT DISTINCT
                ?work
                ?workLabel
                ?publicationDate
                ?typeLabel
                ?languageLabel
              WHERE {
                ?work wdt:P50 wd:#{qid} .

                FILTER NOT EXISTS {
                  VALUES ?excludedType { #{excluded} }
                  ?work wdt:P31/wdt:P279* ?excludedType .
                }
                FILTER NOT EXISTS {
                  ?work wdt:P629 ?editionOf .
                }

                OPTIONAL {
                  ?work wdt:P577 ?publicationDate .
                }

                OPTIONAL {
                  ?work wdt:P31 ?type .
                }

                OPTIONAL {
                  ?work wdt:P407 ?language .
                }

                SERVICE wikibase:label {
                  bd:serviceParam wikibase:language "en" .
                }
              }
              ORDER BY ?publicationDate ?workLabel
              LIMIT #{limit.to_i}
              OFFSET #{offset.to_i}
            SPARQL
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

              cooldown = rand(RETRY_COOLDOWN_RANGE)
              Rails.logger.warn(
                "Wikidata SPARQL request failed; retry #{attempts}/#{MAX_ATTEMPTS - 1} after #{cooldown.round(2)}s"
              )
              sleep(cooldown)
            end
          end

          def perform_sparql_request(query)
            Bench.log("wikidata sparql #{SPARQL_URL}") do
              response = sparql_connection.post(SPARQL_URL) do |req|
                req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
                req.body = { query: query, format: 'json' }.to_query
              end
              break JSON.parse(response.body) if response.success?

              Rails.logger.error("Failed POST #{SPARQL_URL}: #{response.status}")
              nil
            end
          rescue Faraday::Error => e
            Rails.logger.error("Failed POST #{SPARQL_URL}: #{e.class} #{e.message}")
            nil
          end

          def sparql_connection
            @sparql_connection ||= Faraday.new do |f|
              # Application-level retries with randomized cooldown handle transient failures;
              # keep Faraday's retry middleware for connection-level errors as well.
              configure_connection(f)
              f.options.timeout = SPARQL_TIMEOUT
              f.headers['Accept'] = 'application/sparql-results+json'
            end
          end

          def normalize_binding(binding)
            return unless binding.is_a?(Hash)

            work_id = qid_from_uri(binding_value(binding['work']))
            return if work_id.blank?

            {
              'work' => work_id,
              'work_label' => binding_value(binding['workLabel']),
              'publication_date' => binding_value(binding['publicationDate']),
              'type_label' => binding_value(binding['typeLabel']),
              'language_label' => binding_value(binding['languageLabel'])
            }
          end

          def merge_duplicate_works(rows)
            rows.group_by { |row| row['work'] }.map do |_work_id, group|
              first = group.first
              {
                'work' => first['work'],
                'work_label' => first['work_label'],
                'publication_date' => group.filter_map { |row| row['publication_date'] }.min,
                'type_label' => group.filter_map { |row| row['type_label'] }.uniq.join(', ').presence,
                'language_label' => group.filter_map { |row| row['language_label'] }.uniq.join(', ').presence
              }
            end
          end

          def binding_value(node)
            return if node.blank?

            node.is_a?(Hash) ? node['value'].presence : node.to_s.presence
          end

          def qid_from_uri(uri)
            value = uri.to_s.strip
            return if value.blank?

            BaseCaller.normalize_entity_id(value.delete_prefix(WORK_URI_PREFIX))
          end
        end
      end
    end
  end
end
