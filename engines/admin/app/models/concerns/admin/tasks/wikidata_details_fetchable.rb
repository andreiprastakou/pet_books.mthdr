# frozen_string_literal: true

module Admin
  module Tasks
    # Shared perform / normalize / cache for Wikidata entity detail fetch tasks.
    # Subclasses define #details_fetcher, #usable_values_class, #fetch_failure_message.
    module WikidataDetailsFetchable
      extend ActiveSupport::Concern

      def perform
        result = details_fetcher.fetch
        if result
          save_results!(result)
          cache_lookup_entities!(result)
        else
          save_results!(nil, errors: [StandardError.new(fetch_failure_message)])
        end
      end

      def fetched_data_normalized
        values = usable_values_class.call(fetched_data)
        Admin::Wikidata::EntityLookup.enrich(values, fetch_missing: true)
      end

      private

      def cache_lookup_entities!(result)
        data = usable_values_class.call(result)
        Admin::Wikidata::EntityLookup.cache_from_item!(result, data: data)
      end

      def details_fetcher
        raise NotImplementedError
      end

      def usable_values_class
        raise NotImplementedError
      end

      def fetch_failure_message
        raise NotImplementedError
      end
    end
  end
end
