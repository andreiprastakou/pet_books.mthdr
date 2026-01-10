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
  class BaseDataFetchTask < ApplicationRecord
    self.table_name = 'admin_data_fetch_tasks'

    belongs_to :chat, class_name: 'Ai::Chat', optional: true
    belongs_to :target, polymorphic: true

    enum :status, {
      requested: 'requested',
      fetched: 'fetched',
      failed: 'failed',
      rejected: 'rejected',
      verified: 'verified'
    }, default: :requested

    def enqueue_for_processing!
      Admin::DataFetchJob.perform_later(id)
    end

    def save_results!(data, chat:, errors: [])
      if errors.present?
        update!(status: :failed, chat: chat, fetched_data: data,
                fetch_error_details: errors.map(&:message).join(', '))
      else
        update!(status: :fetched, chat: chat, fetched_data: data)
      end
    end

    def review_stage?
      fetched?
    end
  end
end
