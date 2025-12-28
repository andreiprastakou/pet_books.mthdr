# == Schema Information
#
# Table name: ai_chats
# Database name: primary
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  model_id   :string
#
module Ai
  class Chat < AiRecord
    # DEFAULT_MODEL_ID = 'gpt-4.1-nano'.freeze
    DEFAULT_MODEL_ID = 'gpt-4.1'.freeze

    acts_as_chat message_class: 'Ai::Message',
                 tool_call_class: 'Ai::ToolCall'

    validates :model_id, presence: true

    def self.start(model_id = DEFAULT_MODEL_ID)
      create!(model_id: model_id).with_temperature(1)
    end
  end
end
