# frozen_string_literal: true

module Admin
  module ExternalLinkBuilders
    module Goodreads
      # User page for a Goodreads author, e.g. https://www.goodreads.com/author/show/9355
      class Author < Base
        BASE_URL = 'https://www.goodreads.com'

        # Accepts "9355", "/author/show/9355", or slug forms like "9355.Dean_Koontz".
        def self.normalize_id(identificator)
          value = stripped_identificator(identificator)
          return if value.blank?

          extract_id_from_path(value)
        end

        def self.stripped_identificator(identificator)
          value = identificator.to_s.strip
          return if value.blank?

          value = value.delete_prefix('https://').delete_prefix('http://')
          value = value.split('?', 2).first.to_s.split('#', 2).first.presence
          return if value.blank?

          value.delete_prefix('www.goodreads.com').delete_prefix('goodreads.com')
        end

        def self.extract_id_from_path(value)
          if (match = value.match(%r{/author/show/(\d+)}i))
            match[1]
          elsif value.match?(/\A\d+\z/)
            value
          end
        end
        private_class_method :stripped_identificator, :extract_id_from_path

        private

        def build_url(id)
          "#{BASE_URL}/author/show/#{id}"
        end

        def normalized_id
          self.class.normalize_id(identificator)
        end
      end
    end
  end
end
