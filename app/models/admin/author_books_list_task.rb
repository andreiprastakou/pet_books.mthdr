# == Schema Information
#
# Table name: admin_data_fetch_tasks
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
  class AuthorBooksListTask < BaseDataFetchTask
    def self.setup(author)
      create!(target: author)
    end

    alias author target

    def perform
      expert = InfoFetchers::Chats::AuthorBooksListExpert.new
      books_data = expert.ask_books_list(author)
      save_results!(books_data, chat: expert.chat, errors: expert.errors)
    end
  end
end
