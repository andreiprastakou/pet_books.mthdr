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
  class OpenLibraryAuthorSearchTask < BaseDataFetchTask
    def self.setup(author)
      create!(target: author)
    end

    def self.next_unresolved(excluding: nil)
      scope = where(status: :fetched).order(:id)
      scope = scope.where.not(id: excluding.id) if excluding
      scope.first
    end

    alias author target

    def perform
      results = InfoFetchers::OpenLibrary::Api::AuthorSearcher.new(author).search
      save_results!(results)
      results
    end

    def add_author_identity!(author_key)
      olid = ExternalLinks::OpenLibrary::Author.normalize_id(author_key)
      raise ArgumentError, 'Invalid Open Library author key' if olid.blank?

      url = "#{ExternalLinks::OpenLibrary::Author::BASE_URL}/authors/#{olid}"
      external_link = author.external_links.where(external_resource: ExternalResources::OPEN_LIBRARY, url: url).first_or_create!
      author.external_identities.create!(
        external_resource: ExternalResources::OPEN_LIBRARY,
        external_id: olid,
        external_link: external_link
      )
    end
  end
end
