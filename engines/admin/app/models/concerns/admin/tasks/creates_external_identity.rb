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

      def attach_normalized_wikidata_identity!(entity_id, owner:)
        attach_normalized_identity!(
          entity_id,
          owner: owner,
          resource: ExternalResources::WIKIDATA,
          normalizer: Admin::ExternalLinkBuilders::Wikidata.method(:normalize_id),
          error_message: 'Invalid Wikidata entity id'
        )
      end

      def applyable_resource_entries(payload_key)
        Array(fetched_data_normalized[payload_key]).select do |entry|
          Admin::ExternalIdentity.external_resources.key?(entry['external_resource'].to_s)
        end
      end
    end
  end
end
