# frozen_string_literal: true

module Admin
  module ExternalLinkBuilders
    module Goodreads
      # User page for a Goodreads author, e.g. https://www.goodreads.com/author/show/9355
      class Author < SiteAuthor
        BASE_URL = 'https://www.goodreads.com'

        def self.site_host
          'goodreads.com'
        end

        def self.path_regex
          %r{/author/show/(\d+)}i
        end

        def self.bare_regex
          /\A\d+\z/
        end

        def self.author_path(id)
          "/author/show/#{id}"
        end
      end
    end
  end
end
