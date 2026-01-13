module InfoFetchers
  module Chats
    class AuthorBooksListExpert < InfoFetchers::Chats::BaseChat
      has_instructions 'author_books_list_expert.md',
        '<FORMS>' => Book::STANDARD_FORMS.join(', ')

      def ask_books_list(author)
        last_response = chat.ask("Author: #{author.fullname}")
        parse_works_from_response(last_response)
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

      def parse_works_from_response(response)
        JSON.parse(response.content).fetch('works').map do |(title, original_title, year, form, wikipedia_url)|
          {
            title: title,
            original_title: original_title,
            year_published: Integer(year),
            literary_form: form,
            wiki_url: wikipedia_url
          }.compact_blank
        end
      end
    end
  end
end
