module Admin
  module InfoFetchers
    module OpenLibrary
      module Api
        # Shared Open Library entity fetch by key / OLID.
        class EntityDetailsFetcher < BaseCaller
          RESOURCE_TYPES = {
            authors: { segment: 'authors', pattern: 'OL\\d+A', normalize_as: :normalize_author_key },
            works: { segment: 'works', pattern: 'OL\\d+W', normalize_as: :normalize_work_key }
          }.freeze

          def self.configure_resource(type)
            config = RESOURCE_TYPES.fetch(type)
            define_singleton_method(:resource_segment) { config[:segment] }
            define_singleton_method(:id_pattern) { config[:pattern] }
            singleton_class.alias_method config[:normalize_as], :normalize_key
          end

          def initialize(resource_key) # rubocop:disable Lint/MissingSuper
            @resource_key = resource_key
          end

          def fetch
            olid = self.class.normalize_key(resource_key)
            return if olid.blank?

            request_data("/#{self.class.resource_segment}/#{olid}.json")
          end

          def self.normalize_key(key)
            value = key.to_s.strip
            return if value.blank?

            value = value.delete_prefix(BASE_URL)
            value = value.split('?', 2).first
            value = value.split('#', 2).first
            value = value.delete_suffix('.json')
            value[%r{(?:/#{resource_segment}/)?(#{id_pattern})\z}i, 1]&.upcase
          end

          def self.resource_segment
            raise NotImplementedError
          end

          def self.id_pattern
            raise NotImplementedError
          end

          private

          attr_reader :resource_key
        end
      end
    end
  end
end
