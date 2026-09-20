# frozen_string_literal: true

module Admin
  module Tasks
    # Private helper for applying birth/death year from fetched author data.
    # Requires #author and self.class.parse_year.
    module AuthorYearApplicable
      extend ActiveSupport::Concern

      private

      def apply_year!(attribute, year, date_string)
        value = year.presence || self.class.parse_year(date_string)
        raise ArgumentError, 'Year is required' if value.blank?

        author.update!(attribute => value.to_i)
      end
    end
  end
end
