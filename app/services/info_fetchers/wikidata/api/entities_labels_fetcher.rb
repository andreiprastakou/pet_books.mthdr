# frozen_string_literal: true

module InfoFetchers
  module Wikidata
    module Api
      # Batch-fetches labels/descriptions for Wikidata items.
      # Docs: https://www.wikidata.org/w/api.php?action=help&modules=wbgetentities
      # Endpoint: GET /w/api.php?action=wbgetentities&ids=...&props=labels|descriptions
      class EntitiesLabelsFetcher < BaseCaller
        ACTION_API_URL = 'https://www.wikidata.org/w/api.php'
        MAX_IDS_PER_REQUEST = 50
        DEFAULT_LANGUAGE = 'en'

        # @return [Hash{String => Hash}] qid => { 'label' => ..., 'description' => ... }
        def fetch(qids, language: DEFAULT_LANGUAGE)
          normalized = Array(qids).filter_map { |qid| BaseCaller.normalize_entity_id(qid) }.uniq
          return {} if normalized.empty?

          normalized.each_slice(MAX_IDS_PER_REQUEST).with_object({}) do |batch, result|
            data = request_action_data(
              action: 'wbgetentities',
              ids: batch.join('|'),
              props: 'labels|descriptions',
              languages: language,
              languagefallback: 1,
              format: 'json'
            )
            next if data.blank?

            entities = data['entities']
            next unless entities.is_a?(Hash)

            entities.each do |qid, entity|
              next unless entity.is_a?(Hash)
              next if entity.key?('missing')

              result[qid.to_s.upcase] = {
                'label' => localized_text(entity['labels'], language),
                'description' => localized_text(entity['descriptions'], language)
              }
            end
          end
        end

        private

        def request_action_data(params)
          url = "#{ACTION_API_URL}?#{params.compact.to_query}"
          Bench.log("wikidata call #{url}") do
            response = connection.get(url)
            break JSON.parse(response.body) if response.success?

            Rails.logger.error("Failed GET #{url}: #{response.status}")
            nil
          end
        rescue Faraday::Error => e
          Rails.logger.error("Failed GET #{ACTION_API_URL}: #{e.class} #{e.message}")
          nil
        end

        def localized_text(localized, language)
          return if localized.blank? || !localized.is_a?(Hash)

          entry = localized[language] || localized.values.first
          case entry
          when Hash
            (entry['value'] || entry[:value]).presence
          else
            entry.presence
          end
        end
      end
    end
  end
end
