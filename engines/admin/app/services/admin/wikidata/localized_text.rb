# frozen_string_literal: true

module Admin
  module Wikidata
    # Extracts a preferred localized string from Wikidata label/description hashes.
    module LocalizedText
      module_function

      def call(localized, preferred_language: 'en')
        return if localized.blank? || !localized.is_a?(Hash)

        value = localized[preferred_language] || localized[preferred_language.to_sym] || localized.values.first
        case value
        when Hash
          (value['value'] || value[:value]).presence
        else
          value.presence
        end
      end
    end
  end
end
