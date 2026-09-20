# frozen_string_literal: true

module Admin
  module ExternalLinkBuilders
    module Goodreads
      # User page for a Goodreads author, e.g. https://www.goodreads.com/author/show/9355
      class Author < SiteAuthor
        configure_site :goodreads
      end
    end
  end
end
