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
    class LibraryThingBookSearch < BaseTask
      include Admin::Tasks::UnresolvedSearchable
      include Admin::Tasks::CreatesExternalIdentity

      def self.setup(book)
        create!(target: book)
      end

      def book
        Admin::Book.cast(target)
      end

      def perform
        result = Admin::InfoFetchers::LibraryThing::Api::WorkByTitleFetcher.new(book.title).fetch
        save_results!(result)
        result
      end

      def fetched_data_normalized
        link = fetched_data.is_a?(Hash) ? fetched_data.dig('idlist', 'link').presence : nil
        return {} if link.blank?

        { 'external_link' => link }
      end

      def add_work_link!(url)
        normalized_url = Admin::ExternalLinkBuilders::LibraryThing::Work.call(url)
        raise ArgumentError, 'Invalid LibraryThing work url' if normalized_url.blank?

        book.external_links.create!(
          external_resource: ExternalResources::LIBRARYTHING,
          url: normalized_url
        )
      end

      def add_work_identity!(work_id)
        id = Admin::ExternalLinkBuilders::LibraryThing::Work.normalize_id(work_id)
        raise ArgumentError, 'Invalid LibraryThing work id' if id.blank?

        create_introduced_identity!(
          book,
          external_resource: ExternalResources::LIBRARYTHING,
          external_id: id
        )
      end
    end
  end
end
