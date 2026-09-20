# frozen_string_literal: true

module Admin
  module InfoFetchers
    module Wikidata
      module Api
        # Normalizes and de-duplicates SPARQL bindings for author works.
        module AuthorWorksNormalizer
          WORK_URI_PREFIX = 'http://www.wikidata.org/entity/'

          module_function

          def normalize_binding(binding)
            return unless binding.is_a?(Hash)

            work_id = qid_from_uri(binding_value(binding['work']))
            return if work_id.blank?

            {
              'work' => work_id,
              'work_label' => binding_value(binding['workLabel']),
              'publication_date' => binding_value(binding['publicationDate']),
              'type_label' => binding_value(binding['typeLabel']),
              'language_label' => binding_value(binding['languageLabel'])
            }
          end

          def merge_duplicate_works(rows)
            rows.group_by { |row| row['work'] }.map { |_work_id, group| merge_work_group(group) }
          end

          def merge_work_group(group)
            first = group.first
            {
              'work' => first['work'],
              'work_label' => first['work_label'],
              'publication_date' => group.filter_map { |row| row['publication_date'] }.min,
              'type_label' => joined_unique_values(group, 'type_label'),
              'language_label' => joined_unique_values(group, 'language_label')
            }
          end

          def joined_unique_values(group, key)
            group.filter_map { |row| row[key] }.uniq.join(', ').presence
          end

          def binding_value(node)
            return if node.blank?

            node.is_a?(Hash) ? node['value'].presence : node.to_s.presence
          end

          def qid_from_uri(uri)
            value = uri.to_s.strip
            return if value.blank?

            BaseCaller.normalize_entity_id(value.delete_prefix(WORK_URI_PREFIX))
          end
        end
      end
    end
  end
end
