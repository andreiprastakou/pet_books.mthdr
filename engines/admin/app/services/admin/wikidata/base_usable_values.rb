# frozen_string_literal: true

module Admin
  module Wikidata
    # Shared extraction of copyable / decision-helping values from a Wikidata
    # item payload (as stored on admin data-fetch tasks).
    class BaseUsableValues
      STATEMENT_FIELDS = {}.freeze

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

      def usable_statements
        statement_fields.each_with_object({}) do |(property_id, config), result|
          values = statement_values(property_id)
          next if values.empty?

          result[config[:key]] = config[:multi] ? values : values.first
        end
      end

      def statement_values(property_id)
        return [] if fetched_data.blank? || !fetched_data.is_a?(Hash)

        statements = fetched_data['statements'] || fetched_data[:statements]
        return [] if statements.blank? || !statements.is_a?(Hash)

        claims = statements[property_id] || statements[property_id.to_sym]
        return [] if claims.blank?

        preferred = claims.select { |claim| claim.is_a?(Hash) && claim['rank'] == 'preferred' }
        usable = preferred.presence || claims.reject { |claim| claim.is_a?(Hash) && claim['rank'] == 'deprecated' }

        usable.filter_map { |claim| extract_statement_content(claim) }
      end

      def extract_statement_content(claim)
        return unless claim.is_a?(Hash)

        value = claim['value'] || claim[:value]
        return unless value.is_a?(Hash)
        return unless (value['type'] || value[:type]) == 'value'

        content = value['content'] || value[:content]
        case content
        when Hash
          content['time'] || content[:time] || content['text'] || content[:text]
        else
          content
        end
      end

      def usable_sitelinks
        return [] if fetched_data.blank? || !fetched_data.is_a?(Hash)

        raw = fetched_data['sitelinks'] || fetched_data[:sitelinks]
        return [] if raw.blank? || !raw.is_a?(Hash)

        entries = raw.filter_map do |site, link|
          next unless link.is_a?(Hash)

          {
            'title' => link['title'] || link[:title],
            'language' => sitelink_language(site),
            'url' => link['url'] || link[:url]
          }
        end

        en = entries.find { |entry| entry['language'] == 'en' }
        return entries if en.blank?

        [en] + entries.reject { |entry| entry.equal?(en) }
      end

      def sitelink_language(site)
        site.to_s.delete_suffix('wiki')
      end
    end
  end
end
