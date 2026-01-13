module InfoFetchers
  module Chats
    class AuthorsExpert < InfoFetchers::Chats::BaseChat
      has_instructions "authors_expert.md"

      def ask_books_list(fullname)
        chat = setup_chat
        JSON.parse(chat.ask(fullname).content)
      end

      private

      def setup_chat
        Ai::Chat.start.tap do |chat|
          chat.with_instructions(instructions)
        end
      end
    end
  end
end
