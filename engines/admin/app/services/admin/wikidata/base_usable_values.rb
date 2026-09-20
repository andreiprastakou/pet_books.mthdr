# frozen_string_literal: true

module Admin
  module Wikidata
    # Shared extraction of copyable / decision-helping values from a Wikidata
    # item payload (as stored on admin data-fetch tasks).
    # rubocop:disable-next Metrics/ClassLength
    class BaseUsableValues
      STATEMENT_FIELDS = {}.freeze

      EXTERNAL_IDENTITY_FIELDS = {}.freeze

      def self.call(fetched_data)
        new(fetched_data).call
      end

      def initialize(fetched_data)
        @fetched_data = fetched_data
      end

      def call
        result = usable_statements
        sitelinks = usable_sitelinks
        result['sitelinks'] = sitelinks if sitelinks.present?
        result
      end

      private

      attr_reader :fetched_data

      def statement_fields
        self.class::STATEMENT_FIELDS
      end

      def external_identity_fields
        self.class::EXTERNAL_IDENTITY_FIELDS
      end

      def usable_external_identities
        external_identity_fields.filter_map do |property_id, resource|
          values = statement_values(property_id)
          next if values.empty?

          {
            'external_resource' => resource,
            'external_id' => values.first
          }
        end
      end

      def usable_statements
        statement_fields.each_with_object({}) do |(property_id, config), result|
          values = statement_values(property_id)
          next if values.empty?

          result[config[:key]] = config[:multi] ? values : values.first
        end
      end

      def statement_values(property_id)
        claims = claims_for_property(property_id)
        return [] if claims.blank?

        ranked_claims(claims).filter_map { |claim| extract_statement_content(claim) }
      end

      def claims_for_property(property_id)
        return [] if fetched_data.blank? || !fetched_data.is_a?(Hash)

        statements = fetched_data['statements'] || fetched_data[:statements]
        return [] if statements.blank? || !statements.is_a?(Hash)

        statements[property_id] || statements[property_id.to_sym]
      end

      def ranked_claims(claims)
        preferred = claims.select { |claim| claim.is_a?(Hash) && claim['rank'] == 'preferred' }
        preferred.presence || claims.reject { |claim| claim.is_a?(Hash) && claim['rank'] == 'deprecated' }
      end

      def extract_statement_content(claim)
        return unless claim.is_a?(Hash)

        content = statement_value_content(claim)
        return content unless content.is_a?(Hash)

        content['time'] || content[:time] || content['text'] || content[:text]
      end

      def statement_value_content(claim)
        value = claim['value'] || claim[:value]
        return unless value.is_a?(Hash)
        return unless (value['type'] || value[:type]) == 'value'

        value['content'] || value[:content]
      end

      def usable_sitelinks
        raw = sitelinks_hash
        return [] if raw.blank?

        prioritize_english_sitelinks(build_sitelink_entries(raw))
      end

      def sitelinks_hash
        return unless fetched_data.is_a?(Hash)

        raw = fetched_data['sitelinks'] || fetched_data[:sitelinks]
        raw if raw.is_a?(Hash) && raw.present?
      end

      def build_sitelink_entries(raw)
        raw.filter_map do |site, link|
          next unless link.is_a?(Hash)

          {
            'title' => link['title'] || link[:title],
            'language' => sitelink_language(site),
            'url' => link['url'] || link[:url]
          }
        end
      end

      def prioritize_english_sitelinks(entries)
        en = entries.find { |entry| entry['language'] == 'en' }
        return entries if en.blank?

        [en] + entries.reject { |entry| entry.equal?(en) }
      end

      def sitelink_language(site)
        site.to_s.delete_suffix('wiki')
      end

      def extract_localized_text(localized)
        Admin::Wikidata::LocalizedText.call(localized)
      end

      def format_date_fields!(result, keys)
        Array(keys).each do |key|
          raw = result[key]
          next if raw.blank?

          result[key] = format_wikidata_time(raw)
        end
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
