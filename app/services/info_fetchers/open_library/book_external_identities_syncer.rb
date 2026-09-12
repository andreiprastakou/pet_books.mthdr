module InfoFetchers
  module OpenLibrary
    class BookExternalIdentitiesSyncer
      def initialize(external_data_fetch, book)
        @external_data_fetch = external_data_fetch
        @book = book
      end

      def sync!
        identifiers.each do |resource, values|
          next unless allowed_resource?(resource)

          identificator = Array(values).compact_blank.first
          next if identificator.blank?
          next if book.external_identities.exists?(external_resource: resource)

          book.external_identities.create!(
            external_resource: resource,
            identificator: identificator
          )
        end
      end

      private

      attr_reader :external_data_fetch, :book

      def identifiers
        data = external_data_fetch.data
        return {} unless data.is_a?(Hash)

        data['identifiers'] || data[:identifiers] || {}
      end

      def allowed_resource?(resource)
        ExternalIdentity.external_resources.key?(resource.to_s)
      end
    end
  end
end
