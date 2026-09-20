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
    class WikidataBookSearch < BaseTask
      include Admin::Tasks::UnresolvedSearchable
      include Admin::Tasks::AttachesWikidataAuthorIdentity
      include Admin::Tasks::CreatesExternalIdentity
      include Admin::Tasks::WikidataSearchNormalizable

      def self.setup(book)
        create!(target: book)
      end

      def book
        Admin::Book.cast(target)
      end

      def perform
        results = Admin::InfoFetchers::Wikidata::Api::BookSearcher.new(book).search
        save_results!(results)
        results
      end

      def fetched_data_normalized
        normalize_wikidata_search_results('title')
      end

      def add_work_identity!(entity_id)
        attach_normalized_wikidata_identity!(entity_id, owner: book)
      end
    end
  end
end
