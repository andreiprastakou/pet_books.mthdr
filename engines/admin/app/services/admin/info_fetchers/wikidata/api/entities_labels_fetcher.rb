# frozen_string_literal: true

module Admin
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
              merge_batch_labels!(result, batch, language: language)
            end
          end

          private

          def merge_batch_labels!(result, batch, language:)
            entities = fetch_entities(batch, language: language)
            return if entities.blank?

            entities.each do |qid, entity|
              labels = entity_labels_for(entity, language: language)
              result[qid.to_s.upcase] = labels if labels
            end
          end

          def fetch_entities(batch, language:)
            data = request_action_data(
              action: 'wbgetentities',
              ids: batch.join('|'),
              props: 'labels|descriptions',
              languages: language,
              languagefallback: 1,
              format: 'json'
            )
            entities = data&.dig('entities')
            entities if entities.is_a?(Hash)
          end

          def entity_labels_for(entity, language:)
            return unless entity.is_a?(Hash)
            return if entity.key?('missing')

            {
              'label' => localized_text(entity['labels'], language),
              'description' => localized_text(entity['descriptions'], language)
            }
          end

          def request_action_data(params)
            request_json("#{ACTION_API_URL}?#{params.compact.to_query}", log_label: 'wikidata call')
          end

          def localized_text(localized, language)
            Admin::Wikidata::LocalizedText.call(localized, preferred_language: language)
          end

          def connection
            @connection ||= default_api_connection
          end
        end
      end
    end
  end
end
