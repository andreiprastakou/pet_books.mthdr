# frozen_string_literal: true

module Admin
  module Tasks
    # Shared helper for upserting description text from a fetch task.
    module AppliesDescriptionText
      extend ActiveSupport::Concern

      private

      def apply_description_text!(text, owner:, required_label:)
        summary = text.to_s.strip
        raise ArgumentError, "#{required_label} is required" if summary.blank?

        owner.upsert_description_from_source!(self, text: summary, source_label: nil)
      end
    end
  end
end
