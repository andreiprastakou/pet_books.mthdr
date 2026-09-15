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
  class OpenLibraryFetchTask < BaseDataFetchTask
    def self.setup(external_identity)
      create!(target: external_identity)
    end

    alias external_identity target

    def book
      owner = external_identity.owner
      raise ArgumentError, 'Open Library fetch target must belong to a book' unless owner.is_a?(Book)

      owner
    end

    def perform
      result = InfoFetchers::OpenLibrary::Api::BookDetailsFetcher.new(external_identity.external_id).fetch
      if result
        save_results!(result)
      else
        save_results!(nil, errors: [StandardError.new('Failed to fetch Open Library work data')])
      end
    end


    def fetched_identifiers
      data = fetched_data
      return [] unless data.is_a?(Hash)

      identifiers = data['identifiers'] || data[:identifiers] || {}
      return [] unless identifiers.is_a?(Hash)

      identifiers.flat_map do |resource, values|
        next [] unless ExternalIdentity.external_resources.key?(resource.to_s)

        Array(values).compact_blank.map { |external_id| [resource.to_s, external_id.to_s] }
      end
    end

    def fetched_description
      data = fetched_data
      return if data.blank? || !data.is_a?(Hash)

      description = data['description'] || data[:description]
      text = case description
             when Hash
               (description['value'] || description[:value]).presence
             else
               description.presence
             end
      return if text.blank?

      Rails::Html::FullSanitizer.new.sanitize(text.to_s).presence
    end

    def add_identity!(external_resource, external_id)
      resource = external_resource.to_s
      raise ArgumentError, 'Invalid external resource' unless ExternalIdentity.external_resources.key?(resource)

      id = external_id.to_s.strip
      raise ArgumentError, 'External ID is required' if id.blank?

      identity = book.external_identities.create!(external_resource: resource, external_id: id)
      Admin::ExternalIdentityIntroductor.call(identity)
    end


    def apply_summary!(summary, summary_src = nil)
      text = summary.to_s.strip
      raise ArgumentError, 'Summary is required' if text.blank?

      attrs = { summary: text }
      attrs[:summary_src] = summary_src.to_s.strip if summary_src.present?
      book.update!(attrs)
    end

    def fetched_usable_values
      fetched_data&.slice(
        'key',
        'title',
        'description',
        'covers',
        'series',
        'genres',
        'authors',
        'identifiers'
      )
    end
  end
end
