# == Schema Information
#
# Table name: ai_tool_calls
# Database name: primary
#
#  id           :integer          not null, primary key
#  arguments    :text
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  message_id   :integer          not null
#  tool_call_id :string
#
# Indexes
#
#  index_ai_tool_calls_on_message_id    (message_id)
#  index_ai_tool_calls_on_tool_call_id  (tool_call_id)
#
# Foreign Keys
#
#  message_id  (message_id => ai_messages.id)
#
module Ai
  class ToolCall < AiRecord
    acts_as_tool_call message_class: 'Ai::Message'
  end
end
