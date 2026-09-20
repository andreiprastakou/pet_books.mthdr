# frozen_string_literal: true

module Admin
  module ExternalLinkBuilders
    # Shared normalize / build_url skeleton for author pages on external sites.
    class SiteAuthor < Base
      SITES = {
        goodreads: {
          base_url: 'https://www.goodreads.com',
          host: 'goodreads.com',
          path_regex: %r{/author/show/(\d+)}i,
          bare_regex: /\A\d+\z/,
          path: ->(id) { "/author/show/#{id}" }
        },
        library_thing: {
          base_url: 'https://www.librarything.com',
          host: 'librarything.com',
          path_regex: %r{/author/([A-Za-z0-9][A-Za-z0-9_-]*)\z}i,
          bare_regex: /\A[A-Za-z0-9][A-Za-z0-9_-]*\z/,
          path: ->(id) { "/author/#{id}" }
        }
      }.freeze

      def self.configure_site(key)
        config = SITES.fetch(key)
        const_set(:BASE_URL, config[:base_url].freeze)
        define_singleton_method(:site_host) { config[:host] }
        define_singleton_method(:path_regex) { config[:path_regex] }
        define_singleton_method(:bare_regex) { config[:bare_regex] }
        define_singleton_method(:author_path, &config[:path])
      end

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
