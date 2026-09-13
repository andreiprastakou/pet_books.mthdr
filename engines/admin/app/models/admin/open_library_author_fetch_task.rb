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
      raise ArgumentError, 'Open Library author fetch target must belong to an author' unless owner.is_a?(Author)

      owner
    end

    def perform
      result = InfoFetchers::OpenLibrary::Api::AuthorDetailsFetcher.new(external_identity.identificator).fetch
      if result
        save_results!(result)
      else
        save_results!(nil, errors: [StandardError.new('Failed to fetch Open Library author data')])
      end
    end
  end
end
