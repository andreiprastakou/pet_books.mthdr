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
FactoryBot.define do
  factory :ai_chat, class: 'Admin::Ai::Chat' do
    model_id { Admin::Ai::Chat::DEFAULT_MODEL_ID }
  end
end
