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
  class LibraryThingSearchTask < BaseDataFetchTask
    def self.setup(book)
      create!(target: book)
    end

    def self.next_unresolved(excluding: nil)
      scope = where(status: :fetched).order(:id)
      scope = scope.where.not(id: excluding.id) if excluding
      scope.first
    end

    alias book target

    def perform
      result = InfoFetchers::LibraryThing::Api::WorkByTitleFetcher.new(book.title).fetch
      save_results!(result)
      result
    end

    def add_work_identity!(work_id)
      id = ExternalLinks::LibraryThing.normalize_id(work_id)
      raise ArgumentError, 'Invalid LibraryThing work id' if id.blank?

      book.external_identities.create!(
        external_resource: ExternalResources::LIBRARYTHING,
        identificator: id,
        url: ExternalLinks::LibraryThing.call(id)
      )
    end
  end
end
