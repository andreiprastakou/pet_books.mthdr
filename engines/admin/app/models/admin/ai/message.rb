# frozen_string_literal: true

# == Schema Information
#
# Table name: ai_messages
# Database name: primary
#
#  id                 :integer          not null, primary key
#  cache_until_here   :boolean          default(FALSE), not null
#  citations          :json
#  content            :text
#  finish_reason      :string
#  raw_content        :json
#  raw_reasoning      :json
#  role               :string
#  server_tool_calls  :json
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  chat_id            :integer          not null
#
# Indexes
#
#  index_ai_messages_on_chat_id  (chat_id)
#
# Foreign Keys
#
#  chat_id  (chat_id => ai_chats.id)
#
module Admin
  module Ai
    class Message < AiRecord
      acts_as_message chat_class: 'Admin::Ai::Chat'
    end
  end
end
