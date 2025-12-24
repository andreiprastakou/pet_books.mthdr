module InfoFetchers
  module Chats
    class AuthorBooksListParser < InfoFetchers::Chats::BaseChat
      INSTRUCTIONS = <<-INSTRUCTIONS.freeze
        You are a books list parser.

        Your goal: read the given list of works and output it in JSON format.
        JSON output only. It must have structure:
          [[
            "<title>" (string, English),
            <publishing_year> (integer),
            "<type>" (string, one of: #{Book::STANDARD_FORMS.join(',')})
          ], [etc...]]
      INSTRUCTIONS

      def parse_books_list(text)
        last_response = chat.ask(text)
        data = JSON.parse(last_response.content)
        data.map do |(title, year, type)|
          { title: title, year: year, type: type }
        end
      rescue StandardError => e
        Rails.logger.error(e.message)
        @errors = [e]
        []
      end

      def chat
        @chat ||= Ai::Chat.start.tap do |chat|
          chat.with_instructions(INSTRUCTIONS)
        end
      end
    end
  end
end
