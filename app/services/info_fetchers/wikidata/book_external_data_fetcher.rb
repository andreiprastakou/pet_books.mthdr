module InfoFetchers
  module Wikidata
    class BookExternalDataFetcher
      def initialize(external_identity)
        @external_identity = external_identity
      end

      def fetch!
        data = Api::BookDetailsFetcher.new(external_identity.identificator).fetch
        return if data.nil?

        external_identity.external_data_fetches.create!(data: data)
      end

      private

      attr_reader :external_identity
    end
  end
end
