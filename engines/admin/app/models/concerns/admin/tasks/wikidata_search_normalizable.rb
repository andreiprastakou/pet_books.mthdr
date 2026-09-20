# frozen_string_literal: true

module Admin
  module Tasks
    module WikidataSearchNormalizable
      extend ActiveSupport::Concern

      private

      def normalize_wikidata_search_results(label_key)
        Array(fetched_data).filter_map do |item|
          {
            'external_id' => item['id'],
            label_key => item.dig('display-label', 'value'),
            'description' => item.dig('description', 'value')
          }.compact.presence
        end
      end
    end
  end
end
