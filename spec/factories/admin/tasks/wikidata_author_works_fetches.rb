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
FactoryBot.define do
  factory :wikidata_author_works_fetch_task, class: 'Admin::Tasks::WikidataAuthorWorksFetch',
                                             parent: :base_admin_data_fetch_task do
    chat { nil }
    target factory: %i[author], strategy: :create
    input_data { { 'entity_id' => "Q#{SecureRandom.random_number(1_000_000_000)}" } }
  end
end
