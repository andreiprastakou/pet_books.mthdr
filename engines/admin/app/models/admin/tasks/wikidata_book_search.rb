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
      def self.setup(book)
        create!(target: book)
      end

      def self.next_unresolved(excluding: nil)
        scope = where(status: :fetched).order(:id)
        scope = scope.where.not(id: excluding.id) if excluding
        scope.first
      end

      def book
        Admin::Book.cast(target)
      end

      def perform
        results = Admin::InfoFetchers::Wikidata::Api::BookSearcher.new(book).search
        save_results!(results)
        results
      end

      def fetched_usable_values
        Array(fetched_data).filter_map do |item|
          {
            'external_id' => item['id'],
            'title' => item.dig('display-label', 'value'),
            'description' => item.dig('description', 'value')
          }.compact.presence
        end
      end

      def add_work_identity!(entity_id)
        qid = Admin::ExternalLinkBuilders::Wikidata.normalize_id(entity_id)
        raise ArgumentError, 'Invalid Wikidata entity id' if qid.blank?

        identity = book.external_identities.create!(
          external_resource: ExternalResources::WIKIDATA,
          external_id: qid
        )
        Admin::ExternalIdentityIntroductor.call(identity)
      end

      def add_author_identity!(entity_id, author:)
        qid = Admin::ExternalLinkBuilders::Wikidata.normalize_id(entity_id)
        raise ArgumentError, 'Invalid Wikidata entity id' if qid.blank?
        raise ArgumentError, 'Author is required' if author.blank?
        raise ArgumentError, 'Author is not linked to this book' unless book.authors.exists?(id: author.id)

        identity = Admin::Author.cast(author).external_identities.create!(
          external_resource: ExternalResources::WIKIDATA,
          external_id: qid
        )
        Admin::ExternalIdentityIntroductor.call(identity)
      end
    end
  end
end
