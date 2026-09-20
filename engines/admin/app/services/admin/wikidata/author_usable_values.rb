# frozen_string_literal: true

module Admin
  module Wikidata
    # Usable values for person / author Wikidata items.
    # Property meanings: https://www.wikidata.org/wiki/Property:P569 (etc.)
    # People modelling: https://www.wikidata.org/wiki/Wikidata:WikiProject_Biography
    # Writers (within books): https://www.wikidata.org/wiki/Wikidata:WikiProject_Books
    class AuthorUsableValues < BaseUsableValues
      # multi: true  -> array of extracted values
      # multi: false -> first extracted value (or nil)
      STATEMENT_FIELDS = {
        'P569' => { key: 'date_of_birth', multi: false },
        'P570' => { key: 'date_of_death', multi: false },
        'P18' => { key: 'image', multi: false },
        'P27' => { key: 'countries', multi: true },
        'P1412' => { key: 'languages', multi: true },
        'P166' => { key: 'awards', multi: true }
      }.freeze

      EXTERNAL_IDENTITY_FIELDS = {
        'P648' => 'open_library',
        'P2963' => 'goodreads',
        'P7400' => 'librarything'
      }.freeze

      DATE_FIELDS = %w[date_of_birth date_of_death].freeze

      def call
        result = {}
        name = usable_name
        result['name'] = name if name.present?
        result.merge!(usable_statements)
        identities = usable_external_identities
        result['external_identities'] = identities if identities.present?
        sitelinks = usable_sitelinks
        result['sitelinks'] = sitelinks if sitelinks.present?
        format_date_fields!(result, DATE_FIELDS)
        result
      end

      private

      def usable_name
        return if fetched_data.blank? || !fetched_data.is_a?(Hash)

        labels = fetched_data['labels'] || fetched_data[:labels]
        extract_localized_text(labels)
      end
    end
  end
end
