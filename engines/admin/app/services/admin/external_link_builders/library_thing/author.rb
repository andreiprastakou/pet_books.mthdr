# frozen_string_literal: true

module Admin
  module ExternalLinkBuilders
    module LibraryThing
      # User page for a LibraryThing author, e.g. https://www.librarything.com/author/koontzdean
      class Author < Base
        BASE_URL = 'https://www.librarything.com'

        # Accepts "koontzdean", "/author/koontzdean", or full URL-ish paths.
        def self.normalize_id(identificator)
          value = identificator.to_s.strip
          return if value.blank?

          value = value.delete_prefix('https://').delete_prefix('http://')
          value = value.split('?', 2).first.to_s.split('#', 2).first.presence
          return if value.blank?

          value = value.delete_prefix('www.librarything.com').delete_prefix('librarything.com')
          if (match = value.match(%r{/author/([A-Za-z0-9][A-Za-z0-9_-]*)\z}i))
            match[1]
          elsif value.match?(/\A[A-Za-z0-9][A-Za-z0-9_-]*\z/)
            value
          end
        end

        private

        def build_url(id)
          "#{BASE_URL}/author/#{id}"
        end

        def normalized_id
          self.class.normalize_id(identificator)
        end
      end
    end
  end
end
