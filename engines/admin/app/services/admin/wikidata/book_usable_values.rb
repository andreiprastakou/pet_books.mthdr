# frozen_string_literal: true

module Admin
  module Wikidata
    # Usable values for book (work) Wikidata items.
    # Property meanings: https://www.wikidata.org/wiki/Property:P50 (etc.)
    # Book modelling: https://www.wikidata.org/wiki/Wikidata:WikiProject_Books
    class BookUsableValues < BaseUsableValues
      # multi: true  -> array of extracted values
      # multi: false -> first extracted value (or nil)
      STATEMENT_FIELDS = {
        'P50' => { key: 'authors', multi: true },
        'P577' => { key: 'publication_date', multi: false },
        'P179' => { key: 'series', multi: true },
        'P136' => { key: 'genres', multi: true },
        'P166' => { key: 'awards', multi: true },
        'P495' => { key: 'country_of_origin', multi: true },
        'P7937' => { key: 'form_of_work', multi: false }
      }.freeze

      EXTERNAL_IDENTITY_FIELDS = {
        'P648' => 'open_library',
        'P1085' => 'librarything',
        'P8383' => 'goodreads',
        'P2034' => 'gutenberg'
      }.freeze

      def call
        result = usable_statements
        identities = usable_external_identities
        result['external_identities'] = identities if identities.present?
        sitelinks = usable_sitelinks
        result['sitelinks'] = sitelinks if sitelinks.present?
        format_date_fields!(result, %w[publication_date])
        result
      end

      private

      def usable_external_identities
        EXTERNAL_IDENTITY_FIELDS.filter_map do |property_id, resource|
          values = statement_values(property_id)
          next if values.empty?

          {
            'external_resource' => resource,
            'external_id' => values.first
          }
        end
      end
    end
  end
end
