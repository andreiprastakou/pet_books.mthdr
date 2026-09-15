# == Schema Information
#
# Table name: admin_data_fetch_tasks
# Database name: primary
#
#  id                  :integer          not null, primary key
#  fetch_error_details :string
#  fetched_data        :json
#  input_data          :json
#  status              :string           not null
#  target_type         :string           not null
#  type                :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  chat_id             :integer
#  target_id           :integer          not null
#
# Indexes
#
#  index_admin_data_fetch_tasks_on_chat_id  (chat_id)
#  index_admin_data_fetch_tasks_on_target   (target_type,target_id)
#
# Foreign Keys
#
#  chat_id  (chat_id => ai_chats.id)
#
module Admin
  class WikidataFetchTask < BaseDataFetchTask
    def self.setup(external_identity)
      create!(target: external_identity)
    end

    alias external_identity target

    def book
      owner = external_identity.owner
      raise ArgumentError, 'Wikidata fetch target must belong to a book' unless owner.is_a?(::Book)

      Admin::Book.cast(owner)
    end

    def perform
      result = Admin::InfoFetchers::Wikidata::Api::BookDetailsFetcher.new(external_identity.external_id).fetch
      if result
        save_results!(result)
        cache_lookup_entities!(result)
      else
        save_results!(nil, errors: [StandardError.new('Failed to fetch Wikidata item data')])
      end
    end

    def fetched_data_normalized
      values = Admin::Wikidata::BookUsableValues.call(fetched_data)
      Admin::Wikidata::EntityLookup.enrich(values, fetch_missing: true)
    end

    def fetched_description
      data = fetched_data
      return if data.blank? || !data.is_a?(Hash)

      descriptions = data['descriptions'] || data[:descriptions]
      return if descriptions.blank? || !descriptions.is_a?(Hash)

      extract_localized_text(descriptions)
    end

    def fetched_label
      data = fetched_data
      return if data.blank? || !data.is_a?(Hash)

      labels = data['labels'] || data[:labels]
      return if labels.blank? || !labels.is_a?(Hash)

      extract_localized_text(labels)
    end

    private

    def cache_lookup_entities!(result)
      data = Admin::Wikidata::BookUsableValues.call(result)
      Admin::Wikidata::EntityLookup.cache_from_item!(result, data: data)
    end

    def extract_localized_text(localized)
      value = localized['en'] || localized[:en] || localized.values.first
      case value
      when Hash
        (value['value'] || value[:value]).presence
      else
        value.presence
      end
    end
  end
end
