# frozen_string_literal: true

# == Schema Information
#
# Table name: ai_chats
# Database name: primary
#
#  id                 :integer          not null, primary key
#  cancelled          :boolean          default(FALSE), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  ruby_llm_model_id  :integer
#
# Indexes
#
#  index_ai_chats_on_ruby_llm_model_id  (ruby_llm_model_id)
#
# Foreign Keys
#
#  ruby_llm_model_id  (ruby_llm_model_id => ruby_llm_models.id)
#
module Admin
  module Ai
    class Chat < AiRecord
      DEFAULT_MODEL_ID = 'gpt-5-mini'

      acts_as_chat message_class: 'Admin::Ai::Message'

      validates :model_id, presence: true

      def self.start(model_id = DEFAULT_MODEL_ID)
        create!(model_id: model_id).with_temperature(1)
      end
    end
  end
end
