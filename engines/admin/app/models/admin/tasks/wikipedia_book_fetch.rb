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
    class WikipediaBookFetch < BaseTask
      include Admin::WikipediaIntroFetchable

      def self.setup(book)
        create!(target: book)
      end

      def book
        Admin::Book.cast(target)
      end

      def apply_summary!(text)
        summary = text.to_s.strip
        raise ArgumentError, 'Summary is required' if summary.blank?

        book.upsert_description_from_source!(self, text: summary, source_label: nil)
      end

      private

      def wikipedia_owner
        book
      end
    end
  end
end
