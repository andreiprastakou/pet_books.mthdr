# frozen_string_literal: true

module Admin
  module Wikidata
    # Local cache of Wikidata Q-ID labels for usable-values display.
    # Populated after fetch jobs; missing labels can be filled on display.
    class EntityLookup
      QID_PATTERN = /\AQ\d+\z/i

      def self.cache_from_item!(item, usable_values: nil)
        new.cache_from_item!(item, usable_values: usable_values)
      end

      def self.ensure!(qids)
        new.ensure!(qids)
      end

      def self.enrich(values, fetch_missing: false)
        new.enrich(values, fetch_missing: fetch_missing)
      end

      def cache_from_item!(item, usable_values: nil)
        return if item.blank? || !item.is_a?(Hash)

        upsert_from_item_payload!(item)
        values = usable_values.presence || {}
        ensure!(extract_qids(values))
      end

      def ensure!(qids)
        normalized = Array(qids).filter_map { |qid| Admin::WikidataLookupEntity.normalize_qid(qid) }.uniq
        return [] if normalized.empty?

        existing = Admin::WikidataLookupEntity.where(qid: normalized).pluck(:qid)
        missing = normalized - existing
        return [] if missing.empty?

        fetched = InfoFetchers::Wikidata::Api::EntitiesLabelsFetcher.new.fetch(missing)
        now = Time.current
        rows = missing.map do |qid|
          data = fetched[qid] || {}
          {
            qid: qid,
            label: data['label'],
            description: data['description'],
            fetched_at: now,
            created_at: now,
            updated_at: now
          }
        end
        Admin::WikidataLookupEntity.upsert_all(rows, unique_by: :qid)
        missing
      end

      def enrich(values, fetch_missing: false)
        return values if values.blank?

        qids = extract_qids(values)
        ensure!(qids) if fetch_missing
        labels = labels_by_qid(qids)
        enrich_node(values, labels)
      end

      def labels_by_qid(qids)
        normalized = Array(qids).filter_map { |qid| Admin::WikidataLookupEntity.normalize_qid(qid) }.uniq
        return {} if normalized.empty?

        Admin::WikidataLookupEntity.where(qid: normalized).pluck(:qid, :label).to_h
      end

      def extract_qids(node)
        case node
        when Array
          node.flat_map { |value| extract_qids(value) }
        when Hash
          node.except('sitelinks', :sitelinks).values.flat_map { |value| extract_qids(value) }
        when String
          node.match?(QID_PATTERN) ? [node.upcase] : []
        else
          []
        end.uniq
      end

      private

      def upsert_from_item_payload!(item)
        qid = Admin::WikidataLookupEntity.normalize_qid(item['id'] || item[:id])
        return if qid.blank?

        label = localized_text(item['labels'] || item[:labels])
        description = localized_text(item['descriptions'] || item[:descriptions])
        now = Time.current

        Admin::WikidataLookupEntity.upsert(
          {
            qid: qid,
            label: label,
            description: description,
            fetched_at: now,
            created_at: now,
            updated_at: now
          },
          unique_by: :qid
        )
      end

      def localized_text(localized)
        return if localized.blank? || !localized.is_a?(Hash)

        value = localized['en'] || localized[:en] || localized.values.first
        case value
        when Hash
          (value['value'] || value[:value]).presence
        else
          value.presence
        end
      end

      def enrich_node(node, labels)
        case node
        when Array
          node.map { |value| enrich_node(value, labels) }
        when Hash
          node.each_with_object({}) do |(key, value), result|
            result[key] = if key.to_s == 'sitelinks'
                            value
                          else
                            enrich_node(value, labels)
                          end
          end
        when String
          enrich_qid_string(node, labels)
        else
          node
        end
      end

      def enrich_qid_string(value, labels)
        return value unless value.match?(QID_PATTERN)

        qid = value.upcase
        label = labels[qid]
        if label.present?
          { 'id' => qid, 'label' => label }
        else
          { 'id' => qid }
        end
      end
    end
  end
end
