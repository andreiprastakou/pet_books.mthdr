module InfoFetchers
  module Chats
    class AuthorBooksListParser < InfoFetchers::Chats::BaseChat
      has_instructions 'author_books_list_parser.md',
        '<FORMS>' => Book::STANDARD_FORMS.join(', ')


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
          chat.with_instructions(instructions)
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
