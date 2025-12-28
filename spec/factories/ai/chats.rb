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
FactoryBot.define do
  factory :ai_chat, class: 'Ai::Chat' do
    model_id { 'FAKE_MODEL_ID' }
  end
end
