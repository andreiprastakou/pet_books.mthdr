module InfoFetchers
  module Chats
    class AuthorBooksListParser < InfoFetchers::Chats::BaseChat
      INSTRUCTIONS = <<-INSTRUCTIONS.freeze
        You are a books list parser.

        Your goal: read the given list of works and output it in JSON format.
        JSON output only. It must have structure:
          [[
            "<title>" (string, English),
            "<original title>" (string, original title, if present),
            <publishing_year> (integer),
            "<series name>" (string, if present),
            "<type>" (string, one of: #{Book::STANDARD_FORMS.join(',')})
          ], [etc...]]
      INSTRUCTIONS

      def parse_books_list(text)
        last_response = chat.ask(text)
        parse_data_from_response(last_response)
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

      private

      def parse_data_from_response(response)
        data = JSON.parse(response.content)
        data.map do |(title, original_title, year, series, type)|
          {
            title: title,
            original_title: original_title,
            year: year,
            series: series,
            type: type
          }.compact_blank
        end
      end
    end
  end
end
