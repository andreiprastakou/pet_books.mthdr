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
        'P495' => { key: 'country_of_origin', multi: true }
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
        format_publication_date!(result)
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

      def format_publication_date!(result)
        raw = result['publication_date']
        return if raw.blank?

        result['publication_date'] = format_wikidata_time(raw)
      end

      # "+2025-12-09T00:00:00Z" -> "2025-12-09"
      # "+1962-00-00T00:00:00Z" -> "1962"
      def format_wikidata_time(value)
        match = value.to_s.match(/\A\+?(\d{4})(?:-(\d{2}))?(?:-(\d{2}))?/)
        return value unless match

        year, month, day = match.captures
        return year if month.blank? || month == '00'
        return "#{year}-#{month}" if day.blank? || day == '00'

        "#{year}-#{month}-#{day}"
      end
    end
  end
end
