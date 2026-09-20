# frozen_string_literal: true

module Admin
  module Tasks
    # Shared array-search result normalization.
    # Subclasses implement #normalized_search_entry.
    module SearchResultsNormalizable
      extend ActiveSupport::Concern

      def fetched_data_normalized
        data = fetched_data
        return [] unless data.is_a?(Array)

        data.filter_map { |entry| normalized_search_entry(entry) }
      end
    end
  end
end
