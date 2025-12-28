# == Schema Information
#
# Table name: ai_messages
# Database name: primary
#
#  id            :integer          not null, primary key
#  content       :text
#  input_tokens  :integer
#  output_tokens :integer
#  role          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  chat_id       :integer          not null
#  model_id      :string
#  tool_call_id  :integer
#
# Indexes
#
#  index_ai_messages_on_chat_id       (chat_id)
#  index_ai_messages_on_tool_call_id  (tool_call_id)
#
# Foreign Keys
#
#  chat_id       (chat_id => ai_chats.id)
#  tool_call_id  (tool_call_id => ai_tool_calls.id)
#
require 'rails_helper'

RSpec.describe Ai::Message do
  it { is_expected.to belong_to(:chat).class_name(Ai::Chat.name) }
end
