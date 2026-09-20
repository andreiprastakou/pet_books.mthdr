# frozen_string_literal: true

module Admin
  module Tasks
    # Creates an external identity and runs ExternalIdentityIntroductor.
    module CreatesExternalIdentity
      extend ActiveSupport::Concern

      private

      def create_introduced_identity!(owner, external_resource:, external_id:)
        identity = owner.external_identities.create!(
          external_resource: external_resource,
          external_id: external_id
        )
        Admin::ExternalIdentityIntroductor.call(identity)
      end

      def attach_normalized_identity!(raw_id, owner:, resource:, normalizer:, error_message:)
        id = normalizer.call(raw_id)
        raise ArgumentError, error_message if id.blank?

        create_introduced_identity!(owner, external_resource: resource, external_id: id)
      end

      def attach_open_library_author_to!(owner, author_key)
        attach_normalized_identity!(
          author_key,
          owner: owner,
          resource: ExternalResources::OPEN_LIBRARY,
          normalizer: Admin::ExternalLinkBuilders::OpenLibrary::Author.method(:normalize_id),
          error_message: 'Invalid Open Library author key'
        )
      end

      def attach_library_thing_work_to!(owner, work_id)
        attach_normalized_identity!(
          work_id,
          owner: owner,
          resource: ExternalResources::LIBRARYTHING,
          normalizer: Admin::ExternalLinkBuilders::LibraryThing::Work.method(:normalize_id),
          error_message: 'Invalid LibraryThing work id'
        )
      end

      def attach_normalized_wikidata_identity!(entity_id, owner:)
        attach_normalized_identity!(
          entity_id,
          owner: owner,
          resource: ExternalResources::WIKIDATA,
          normalizer: Admin::ExternalLinkBuilders::Wikidata.method(:normalize_id),
          error_message: 'Invalid Wikidata entity id'
        )
      end
    end
  end
end
