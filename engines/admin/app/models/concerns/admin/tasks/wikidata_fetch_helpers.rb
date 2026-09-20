# frozen_string_literal: true

module Admin
  module Tasks
    # Shared Wikidata fetch helpers (year/url parsing + sitelink/identity selectors).
    module WikidataFetchHelpers
      extend ActiveSupport::Concern

      include Admin::Tasks::UrlHost

      class_methods do
        def parse_year(date_string)
          date_string.to_s[/\b(\d{4})\b/, 1]&.to_i
        end

        def wikipedia_url?(url)
          host = host_from_url(url)
          host.present? && host.end_with?('wikipedia.org')
        end
      end

      def applyable_external_identities
        Array(fetched_data_normalized['external_identities']).select do |entry|
          Admin::ExternalIdentity.external_resources.key?(entry['external_resource'].to_s)
        end
      end

      def wikipedia_sitelinks
        Array(fetched_data_normalized['sitelinks']).select { |link| self.class.wikipedia_url?(link['url']) }
      end

      def other_sitelinks
        Array(fetched_data_normalized['sitelinks']).filter_map do |link|
          url = link['url'].presence
          next if url.blank? || self.class.wikipedia_url?(url)

          host = self.class.host_from_url(url)
          next if host.blank?

          { 'external_resource' => host, 'url' => url }
        end
      end
    end
  end
end
