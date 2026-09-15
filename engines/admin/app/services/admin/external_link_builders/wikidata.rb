# frozen_string_literal: true

module Admin
  module ExternalLinkBuilders
    # User page for a Wikidata entity, e.g. https://www.wikidata.org/wiki/Q137179018
    class Wikidata < Base
      BASE_URL = 'https://www.wikidata.org'

      # Accepts "Q137179018", "/wiki/Q137179018", or full URL-ish paths.
      def self.normalize_id(identificator)
        value = identificator.to_s.strip
        return if value.blank?

        value = value.delete_prefix('https://').delete_prefix('http://')
        value = value.split('?', 2).first.to_s.split('#', 2).first.presence
        return if value.blank?

        value = value.delete_prefix('www.wikidata.org').delete_prefix('wikidata.org')
        value[%r{(?:/wiki/|/entities/items/)?(Q\d+)\z}i, 1]&.upcase
      end

      private

      def build_url(id)
        "#{BASE_URL}/wiki/#{id}"
      end

      def normalized_id
        self.class.normalize_id(identificator)
      end
    end
  end
end
