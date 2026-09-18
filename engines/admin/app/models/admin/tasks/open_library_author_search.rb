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
      def self.setup(author)
        create!(target: author)
      end

      def self.next_unresolved(excluding: nil)
        scope = where(status: :fetched).order(:id)
        scope = scope.where.not(id: excluding.id) if excluding
        scope.first
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
        olid = Admin::ExternalLinkBuilders::OpenLibrary::Author.normalize_id(author_key)
        raise ArgumentError, 'Invalid Open Library author key' if olid.blank?

        identity = author.external_identities.create!(
          external_resource: ExternalResources::OPEN_LIBRARY,
          external_id: olid
        )
        Admin::ExternalIdentityIntroductor.call(identity)
      end

      def fetched_data_normalized
        data = fetched_data
        return [] unless data.is_a?(Array)

        data.filter_map { |entry| normalized_search_entry(entry) }
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
