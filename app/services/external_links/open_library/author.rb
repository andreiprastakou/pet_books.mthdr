# frozen_string_literal: true

module ExternalLinks
  module OpenLibrary
    # User page for an Open Library author, e.g. https://openlibrary.org/authors/OL1394865A
    class Author < Base
      BASE_URL = 'https://openlibrary.org'

      # Accepts "OL1394865A", "/authors/OL1394865A", or full URL-ish paths.
      def self.normalize_id(identificator)
        value = identificator.to_s.strip
        return if value.blank?

        value = value.delete_prefix('https://').delete_prefix('http://')
        value = value.split('?', 2).first.to_s.split('#', 2).first.presence
        return if value.blank?

        value = value.delete_prefix('openlibrary.org')
        value = value.delete_suffix('.json')
        value[%r{(?:/authors/)?(OL\d+A)\z}i, 1]&.upcase
      end

      private

      def build_url(id)
        "#{BASE_URL}/authors/#{id}"
      end

      def normalized_id
        self.class.normalize_id(identificator)
      end
    end
  end
end
