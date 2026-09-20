# frozen_string_literal: true

module Admin
  module Tasks
    # Attaches a Wikidata author identity to a book-linked author.
    # Requires #book.
    module AttachesWikidataAuthorIdentity
      extend ActiveSupport::Concern

      include Admin::Tasks::CreatesExternalIdentity

      def add_author_identity!(entity_id, author:)
        qid = Admin::ExternalLinkBuilders::Wikidata.normalize_id(entity_id)
        raise ArgumentError, 'Invalid Wikidata entity id' if qid.blank?
        raise ArgumentError, 'Author is required' if author.blank?
        raise ArgumentError, 'Author is not linked to this book' unless book.authors.exists?(id: author.id)

        create_introduced_identity!(
          Admin::Author.cast(author),
          external_resource: ExternalResources::WIKIDATA,
          external_id: qid
        )
      end
    end
  end
end
