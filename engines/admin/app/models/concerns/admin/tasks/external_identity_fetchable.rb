# frozen_string_literal: true

module Admin
  module Tasks
    # Shared setup / identity / link helpers for Open Library and Wikidata fetch tasks
    # whose target is an ExternalIdentity. Subclasses define #author or #book.
    module ExternalIdentityFetchable
      extend ActiveSupport::Concern

      include Admin::Tasks::CreatesExternalIdentity

      class_methods do
        def setup(external_identity)
          create!(target: external_identity)
        end
      end

      included do
        alias_method :external_identity, :target
      end

      def add_identity!(external_resource, external_id)
        resource = external_resource.to_s
        unless Admin::ExternalIdentity.external_resources.key?(resource)
          raise ArgumentError, 'Invalid external resource'
        end

        id = external_id.to_s.strip
        raise ArgumentError, 'External ID is required' if id.blank?

        create_introduced_identity!(identity_owner, external_resource: resource, external_id: id)
      end

      def add_link!(url, external_resource:)
        resource = external_resource.to_s.strip
        raise ArgumentError, 'External resource is required' if resource.blank?

        link_url = url.to_s.strip
        raise ArgumentError, 'URL is required' if link_url.blank?

        link = identity_owner.external_links.find_or_initialize_by(url: link_url)
        link.external_resource = resource
        link.save!
        link
      end

      def identity_owner
        return author if respond_to?(:author, true)
        return book if respond_to?(:book, true)

        raise NotImplementedError, "#{self.class} must define #author or #book"
      end

      def cast_identity_owner!(expected_class, admin_class, message)
        owner = external_identity.owner
        raise ArgumentError, message unless owner.is_a?(expected_class)

        admin_class.cast(owner)
      end
    end
  end
end
