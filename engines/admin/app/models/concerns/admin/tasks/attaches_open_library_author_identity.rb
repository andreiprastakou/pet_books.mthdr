# frozen_string_literal: true

module Admin
  module Tasks
    # Attaches an Open Library author identity to a book-linked author.
    # Requires #book.
    module AttachesOpenLibraryAuthorIdentity
      extend ActiveSupport::Concern

      include Admin::Tasks::CreatesExternalIdentity

      def add_author_identity!(author_key, author:)
        olid = Admin::ExternalLinkBuilders::OpenLibrary::Author.normalize_id(author_key)
        raise ArgumentError, 'Invalid Open Library author key' if olid.blank?
        raise ArgumentError, 'Author is required' if author.blank?
        raise ArgumentError, 'Author is not linked to this book' unless book.authors.exists?(id: author.id)

        create_introduced_identity!(
          Admin::Author.cast(author),
          external_resource: ExternalResources::OPEN_LIBRARY,
          external_id: olid
        )
      end
    end
  end
end
