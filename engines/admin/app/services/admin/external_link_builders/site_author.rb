# frozen_string_literal: true

module Admin
  module ExternalLinkBuilders
    # Shared normalize / build_url skeleton for author pages on external sites.
    # Subclasses supply site_host, path_regex, bare_regex, author_path, and BASE_URL.
    class SiteAuthor < Base
      def self.normalize_id(identificator)
        normalize_path_id(
          identificator,
          host: site_host,
          path_regex: path_regex,
          bare_regex: bare_regex
        )
      end

      private

      def build_url(id)
        "#{self.class::BASE_URL}#{self.class.author_path(id)}"
      end

      def normalized_id
        self.class.normalize_id(identificator)
      end
    end
  end
end
