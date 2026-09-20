# frozen_string_literal: true

module Admin
  module Tasks
    # Shared perform for Open Library entity detail fetch tasks.
    # Subclasses define #details_fetcher and #fetch_failure_message.
    module OpenLibraryDetailsFetchable
      extend ActiveSupport::Concern

      def perform
        result = details_fetcher.fetch
        if result
          save_results!(result)
        else
          save_results!(nil, errors: [StandardError.new(fetch_failure_message)])
        end
      end

      private

      def details_fetcher
        raise NotImplementedError
      end

      def fetch_failure_message
        raise NotImplementedError
      end
    end
  end
end
