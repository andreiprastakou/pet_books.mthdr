# frozen_string_literal: true

module Admin
  module Wikidata
    # Local cache of Wikidata Q-ID labels for usable-values display.
    # Populated after fetch jobs; missing labels can be filled on display.
    # rubocop:disable-next Metrics/ClassLength
    class EntityLookup
      QID_PATTERN = /\AQ\d+\z/i

      def self.cache_from_item!(item, data: nil)
        new.cache_from_item!(item, data: data)
      end

      def self.ensure!(qids)
        new.ensure!(qids)
      end

      def self.enrich(values, fetch_missing: false)
        new.enrich(values, fetch_missing: fetch_missing)
      end

      def cache_from_item!(item, data: nil)
        return if item.blank? || !item.is_a?(Hash)

        upsert_from_item_payload!(item)
        values = data.presence || {}
        ensure!(extract_qids(values))
      end

      def ensure!(qids)
        missing = missing_qids(qids)
        return [] if missing.empty?

        upsert_missing_labels!(missing)
        missing
      end

      def missing_qids(qids)
        normalized = Array(qids).filter_map { |qid| Admin::WikidataLookupEntity.normalize_qid(qid) }.uniq
        return [] if normalized.empty?

        existing = Admin::WikidataLookupEntity.where(qid: normalized).pluck(:qid)
        normalized - existing
      end

      def upsert_missing_labels!(missing)
        fetched = Admin::InfoFetchers::Wikidata::Api::EntitiesLabelsFetcher.new.fetch(missing)
        now = Time.current
        rows = missing.map { |qid| lookup_row_for(qid, fetched[qid] || {}, now: now) }
        # rubocop:disable-next Rails/SkipsModelValidations
        Admin::WikidataLookupEntity.upsert_all(rows, unique_by: :qid)
      end

      def lookup_row_for(qid, data, now:)
        {
          qid: qid,
          label: data['label'],
          description: data['description'],
          fetched_at: now,
          created_at: now,
          updated_at: now
        }
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
        when Array then node.flat_map { |value| extract_qids(value) }
        when Hash then extract_qids_from_hash(node)
        when String then extract_qid_from_string(node)
        else []
        end.uniq
      end

      def extract_qids_from_hash(node)
        node.except('sitelinks', :sitelinks, 'external_identities', :external_identities)
            .values.flat_map { |value| extract_qids(value) }
      end

      def extract_qid_from_string(node)
        node.match?(QID_PATTERN) ? [node.upcase] : []
      end

      private

      def upsert_from_item_payload!(item)
        qid = Admin::WikidataLookupEntity.normalize_qid(item['id'] || item[:id])
        return if qid.blank?

        # rubocop:disable-next Rails/SkipsModelValidations
        Admin::WikidataLookupEntity.upsert(
          lookup_row_for(qid, item_texts(item), now: Time.current),
          unique_by: :qid
        )
      end

      def item_texts(item)
        {
          'label' => localized_text(item['labels'] || item[:labels]),
          'description' => localized_text(item['descriptions'] || item[:descriptions])
        }
      end

      def localized_text(localized)
        Admin::Wikidata::LocalizedText.call(localized)
      end

      def enrich_node(node, labels, field: nil)
        case node
        when Array then node.map { |value| enrich_node(value, labels, field: field) }
        when Hash then enrich_hash_node(node, labels)
        when String then enrich_qid_string(node, labels, field: field)
        else node
        end
      end

      def enrich_hash_node(node, labels)
        node.each_with_object({}) do |(key, value), result|
          result[key] = if %w[sitelinks external_identities].include?(key.to_s)
                          value
                        else
                          enrich_node(value, labels, field: key)
                        end
        end
      end

      def enrich_qid_string(value, labels, field: nil)
        return value unless value.match?(QID_PATTERN)

        qid = value.upcase
        label = labels[qid]
        label_key = field.to_s == 'authors' ? 'name' : 'label'
        if label.present?
          { 'external_id' => qid, label_key => label }
        else
          { 'external_id' => qid }
        end
      end
    end
  end
end
