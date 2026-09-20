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
    class OpenLibraryAuthorSearch < BaseTask
      include Admin::Tasks::UnresolvedSearchable
      include Admin::Tasks::SearchResultsNormalizable
      include Admin::Tasks::CreatesExternalIdentity

      def self.setup(author)
        create!(target: author)
      end

      def author
        Admin::Author.cast(target)
      end

      def perform
        results = Admin::InfoFetchers::OpenLibrary::Api::AuthorSearcher.new(author).search
        save_results!(results)
        results
      end

      def add_author_identity!(author_key)
        attach_normalized_identity!(
          author_key,
          owner: author,
          resource: ExternalResources::OPEN_LIBRARY,
          normalizer: Admin::ExternalLinkBuilders::OpenLibrary::Author.method(:normalize_id),
          error_message: 'Invalid Open Library author key'
        )
      end

      def normalized_search_entry(entry)
        return unless entry.is_a?(Hash)

        {
          'external_id' => entry['key'],
          'name' => entry['name'],
          'birth_date' => entry['birth_date'],
          'death_date' => entry['death_date'],
          'type' => entry['type'],
          'ratings_count' => entry['ratings_count']
        }.compact_blank.presence
      end
    end
  end
end
