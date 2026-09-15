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
  class OpenLibraryAuthorFetchTask < BaseDataFetchTask
    def self.setup(external_identity)
      create!(target: external_identity)
    end

    alias external_identity target

    def author
      owner = external_identity.owner
      raise ArgumentError, 'Open Library author fetch target must belong to an author' unless owner.is_a?(::Author)

      Admin::Author.cast(owner)
    end

    def perform
      result = Admin::InfoFetchers::OpenLibrary::Api::AuthorDetailsFetcher.new(external_identity.external_id).fetch
      if result
        save_results!(result)
      else
        save_results!(nil, errors: [StandardError.new('Failed to fetch Open Library author data')])
      end
    end

    def fetched_usable_values
      data = fetched_data
      return {} unless data.is_a?(Hash)

      {
        'name' => data['name'],
        'personal_name' => data['personal_name'],
        'birth_date' => data['birth_date'],
        'death_date' => data['death_date'],
        'bio' => fetched_text_value(data['bio']),
        'remote_ids' => fetched_remote_ids(data['remote_ids']),
        'links' => fetched_links(data['links']),
        'photos' => fetched_photos(data['photos']),
        'revision' => data['revision']
      }.compact_blank
    end

    private

    def fetched_text_value(value)
      case value
      when Hash
        value['value'].presence
      else
        value.presence
      end
    end

    def fetched_remote_ids(remote_ids)
      return [] unless remote_ids.is_a?(Hash)

      remote_ids.filter_map do |resource, external_id|
        id = external_id.presence
        next unless id

        { 'external_resource' => resource.to_s, 'external_id' => id.to_s }
      end
    end

    def fetched_links(links)
      return [] unless links.is_a?(Array)

      links.filter_map do |link|
        next unless link.is_a?(Hash)

        url = link['url'].presence
        next unless url

        { 'label' => link['title'], 'url' => url }.compact_blank
      end
    end

    def fetched_photos(photos)
      return [] unless photos.is_a?(Array)

      photos.select { |photo| photo.is_a?(Integer) }
    end
  end
end
