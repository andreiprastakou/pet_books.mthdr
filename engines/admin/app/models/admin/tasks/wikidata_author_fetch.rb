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
    class WikidataAuthorFetch < BaseTask
      include Admin::Tasks::ExternalIdentityFetchable
      include Admin::Tasks::WikidataFetchHelpers
      include Admin::Tasks::WikidataDetailsFetchable
      include Admin::Tasks::AuthorYearApplicable

      def author
        cast_identity_owner!(
          ::Author,
          Admin::Author,
          'Wikidata author fetch target must belong to an author'
        )
      end

      def apply_birth_year!(year = nil)
        apply_year!(:birth_year, year, fetched_data_normalized['date_of_birth'])
      end

      def apply_death_year!(year = nil)
        apply_year!(:death_year, year, fetched_data_normalized['date_of_death'])
      end

      private

      def details_fetcher
        Admin::InfoFetchers::Wikidata::Api::AuthorDetailsFetcher.new(external_identity.external_id)
      end

      def usable_values_class
        Admin::Wikidata::AuthorUsableValues
      end

      def fetch_failure_message
        'Failed to fetch Wikidata author data'
      end
    end
  end
end
