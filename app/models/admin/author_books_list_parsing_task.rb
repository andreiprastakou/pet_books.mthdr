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
  class AuthorBooksListParsingTask < BaseDataFetchTask
    def self.setup(author, text:)
      create!(target: author, input_data: { text: text })
    end

    alias author target

    def perform
      parser = InfoFetchers::Chats::AuthorBooksListParser.new
      books_data = parser.parse_books_list(input_data.fetch("text"))
      save_results!(books_data, chat: parser.chat, errors: parser.errors)
    end
  end
end
