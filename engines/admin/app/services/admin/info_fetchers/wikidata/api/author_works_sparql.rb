# frozen_string_literal: true

module Admin
  module InfoFetchers
    module Wikidata
      module Api
        # SPARQL for works authored by a Wikidata person (P50).
        module AuthorWorksSparql
          QUERY_TEMPLATE = <<~SPARQL
            SELECT DISTINCT
              ?work
              ?workLabel
              ?publicationDate
              ?typeLabel
              ?languageLabel
            WHERE {
              ?work wdt:P50 wd:%<qid>s .

              FILTER NOT EXISTS {
                VALUES ?excludedType { %<excluded>s }
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
            LIMIT %<limit>s
            OFFSET %<offset>s
          SPARQL

          module_function

          def query(qid:, excluded_types:, limit:, offset:)
            format(
              QUERY_TEMPLATE,
              qid: qid,
              excluded: excluded_types.map { |type| "wd:#{type}" }.join(' '),
              limit: limit.to_i,
              offset: offset.to_i
            )
          end
        end
      end
    end
  end
end
