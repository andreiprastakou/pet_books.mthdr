# frozen_string_literal: true

module Admin
  module ExternalLinkBuilders
    module LibraryThing
      # User page for a LibraryThing author, e.g. https://www.librarything.com/author/koontzdean
      class Author < SiteAuthor
        configure_site :library_thing
      end
    end
  end
end
