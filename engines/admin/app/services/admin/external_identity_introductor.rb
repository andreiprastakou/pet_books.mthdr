# frozen_string_literal: true

module Admin
  # Attaches an ExternalLink (when a URL builder exists) and enqueues a fetch task
  # (when one is defined for the resource + owner) after an ExternalIdentity is
  # created or its external_id changes.
  class ExternalIdentityIntroductor
    LINK_BUILDERS_BY_RESOURCE = {
      ExternalResources::OPEN_LIBRARY => {
        book: Admin::ExternalLinkBuilders::OpenLibrary::Work,
        author: Admin::ExternalLinkBuilders::OpenLibrary::Author
      },
      ExternalResources::WIKIDATA => {
        book: Admin::ExternalLinkBuilders::Wikidata,
        author: Admin::ExternalLinkBuilders::Wikidata
      },
      ExternalResources::LIBRARYTHING => {
        book: Admin::ExternalLinkBuilders::LibraryThing::Work,
        author: Admin::ExternalLinkBuilders::LibraryThing::Author
      },
      ExternalResources::GOODREADS => {
        book: Admin::ExternalLinkBuilders::Goodreads::Work,
        author: Admin::ExternalLinkBuilders::Goodreads::Author
      }
    }.freeze

    FETCH_TASKS = {
      [ExternalResources::OPEN_LIBRARY, :book] => Admin::Tasks::OpenLibraryBookFetch,
      [ExternalResources::OPEN_LIBRARY, :author] => Admin::Tasks::OpenLibraryAuthorFetch,
      [ExternalResources::WIKIDATA, :book] => Admin::Tasks::WikidataBookFetch,
      [ExternalResources::WIKIDATA, :author] => Admin::Tasks::WikidataAuthorFetch
    }.freeze

    def self.call(external_identity)
      new(external_identity).call
    end

    def self.link_builder_for(external_resource, owner)
      builders_for(owner)[external_resource.to_s]
    end

    def self.builders_for(owner)
      kind = owner_kind(owner)
      return {} unless kind

      LINK_BUILDERS_BY_RESOURCE.transform_values { |by_kind| by_kind[kind] }
    end

    def self.owner_kind(owner)
      klass = owner.is_a?(Module) ? owner : owner.class
      return :book if klass <= ::Book
      return :author if klass <= ::Author

      nil
    end

    def initialize(external_identity)
      @external_identity = external_identity
      @external_id_changed = external_identity.saved_change_to_external_id?
    end

    def call
      return external_identity unless @external_id_changed

      attach_external_link!
      enqueue_fetch_task!
      external_identity
    end

    private

    attr_reader :external_identity

    def attach_external_link!
      url = external_link_url
      return if url.blank?

      link = find_or_create_external_link!(url)
      return if external_identity.external_link_id == link.id

      external_identity.update!(external_link: link)
    end

    def external_link_url
      builder = self.class.link_builder_for(external_identity.external_resource, owner)
      return unless builder

      builder.call(external_identity.external_id).presence
    end

    def find_or_create_external_link!(url)
      owner.external_links.where(external_resource: external_identity.external_resource, url: url)
           .first_or_create!
    end

    def enqueue_fetch_task!
      task_class = FETCH_TASKS[[external_identity.external_resource, self.class.owner_kind(owner)]]
      return unless task_class

      task_class.setup(external_identity).enqueue_for_processing!
    end

    def owner
      raw = external_identity.owner
      case raw
      when ::Book then Admin::Book.cast(raw)
      when ::Author then Admin::Author.cast(raw)
      else raw
      end
    end
  end
end
