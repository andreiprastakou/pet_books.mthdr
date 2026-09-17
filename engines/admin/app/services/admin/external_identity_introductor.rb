# frozen_string_literal: true

module Admin
  # Attaches an ExternalLink (when a URL builder exists) and enqueues a fetch task
  # (when one is defined for the resource + owner) after an ExternalIdentity is
  # created or its external_id changes.
  class ExternalIdentityIntroductor
    BOOK_LINK_BUILDERS = {
      ExternalResources::OPEN_LIBRARY => Admin::ExternalLinkBuilders::OpenLibrary::Work,
      ExternalResources::WIKIDATA => Admin::ExternalLinkBuilders::Wikidata,
      ExternalResources::LIBRARYTHING => Admin::ExternalLinkBuilders::LibraryThing::Work,
      ExternalResources::GOODREADS => Admin::ExternalLinkBuilders::Goodreads::Work
    }.freeze

    AUTHOR_LINK_BUILDERS = {
      ExternalResources::OPEN_LIBRARY => Admin::ExternalLinkBuilders::OpenLibrary::Author,
      ExternalResources::WIKIDATA => Admin::ExternalLinkBuilders::Wikidata,
      ExternalResources::LIBRARYTHING => Admin::ExternalLinkBuilders::LibraryThing::Author,
      ExternalResources::GOODREADS => Admin::ExternalLinkBuilders::Goodreads::Author
    }.freeze

    FETCH_TASKS = {
      [ExternalResources::OPEN_LIBRARY, :book] => Admin::Tasks::OpenLibraryBookFetch,
      [ExternalResources::OPEN_LIBRARY, :author] => Admin::Tasks::OpenLibraryAuthorFetch
    }.freeze

    def self.call(external_identity)
      new(external_identity).call
    end

    def self.link_builder_for(external_resource, owner)
      builders_for(owner)[external_resource.to_s]
    end

    def self.builders_for(owner)
      case owner_kind(owner)
      when :book then BOOK_LINK_BUILDERS
      when :author then AUTHOR_LINK_BUILDERS
      else
        {}
      end
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
      builder = self.class.link_builder_for(external_identity.external_resource, owner)
      return unless builder

      url = builder.call(external_identity.external_id)
      return if url.blank?

      link = owner.external_links.where(external_resource: external_identity.external_resource, url: url)
                  .first_or_create!
      return if external_identity.external_link_id == link.id

      external_identity.update!(external_link: link)
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
