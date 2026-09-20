# frozen_string_literal: true

module Admin
  # Makes Admin STI wrappers writable and castable from main-app records.
  module Castable
    extend ActiveSupport::Concern

    def readonly?
      false
    end

    class_methods do
      def cast(record)
        return record if record.is_a?(self)
        return new(record.attributes) if record.new_record?

        record.becomes(self)
      end
    end
  end
end
