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
  module Tasks
    class OpenLibraryBookSearch < BaseTask
      include Admin::Tasks::UnresolvedSearchable
      include Admin::Tasks::AttachesOpenLibraryAuthorIdentity
      include Admin::Tasks::SearchResultsNormalizable
      include Admin::Tasks::CreatesExternalIdentity

      def self.setup(book)
        create!(target: book)
      end

      def book
        Admin::Book.cast(target)
      end

      def perform
        results = Admin::InfoFetchers::OpenLibrary::Api::BookSearcher.new(book).search
        save_results!(results)
        results
      end

      def add_work_identity!(work_key)
        olid = Admin::InfoFetchers::OpenLibrary::Api::BookDetailsFetcher.normalize_work_key(work_key)
        raise ArgumentError, 'Invalid Open Library work key' if olid.blank?

        create_introduced_identity!(
          book,
          external_resource: ExternalResources::OPEN_LIBRARY,
          external_id: olid
        )
      end

      def normalized_search_entry(entry)
        return unless entry.is_a?(Hash)

        {
          'external_id' => entry['key'],
          'title' => entry['title'],
          'first_publish_year' => entry['first_publish_year'],
          'authors' => fetched_author_entries(entry)
        }.compact_blank.presence
      end

      private

      def fetched_author_entries(entry)
        author_ids = entry['author_key']
        author_names = entry['author_name']
        return [] unless author_ids.is_a?(Array)

        names = author_names.is_a?(Array) ? author_names : []
        author_ids.filter_map.with_index do |external_id, index|
          id = external_id.presence
          next unless id

          { 'external_id' => id, 'name' => names[index] }.compact
        end
      end
    end
  end
end
