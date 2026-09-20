# frozen_string_literal: true

module Admin
  module ExternalLinkBuilders
    module LibraryThing
      # User page for a LibraryThing author, e.g. https://www.librarything.com/author/koontzdean
      class Author < SiteAuthor
        SITE = {
          base_url: 'https://www.librarything.com',
          host: 'librarything.com',
          path_regex: %r{/author/([A-Za-z0-9][A-Za-z0-9_-]*)\z}i,
          bare_regex: /\A[A-Za-z0-9][A-Za-z0-9_-]*\z/,
          path_template: '/author/%s'
        }.freeze

        BASE_URL = SITE[:base_url]

        def self.site_host
          SITE[:host]
        end

        def self.path_regex
          SITE[:path_regex]
        end

        def self.bare_regex
          SITE[:bare_regex]
        end

        def self.author_path(id)
          format(SITE[:path_template], id)
        end
      end
    end
  end
end
