module InfoFetchers
  module Chats
    class BookSummaryWriter < InfoFetchers::Chats::BaseChat
      has_instructions 'book_summary_writer.md',
        '<STANDARD_FORMS>' => Book::STANDARD_FORMS.join(', ')

      def ask(book)
        last_response = ask_chat(book)
        parse_summary_from_response(last_response)
      rescue StandardError => e
        Rails.logger.error(e.message)
        @errors = [e]
        []
      end

      def chat
        @chat ||= Ai::Chat.start.tap do |chat|
          chat.with_instructions(
            instructions(
              '<GENRES>' => Genre.pluck(:name).join(',')
            )
          )
        end
      end

      private

      def parse_summary_from_response(response)
        JSON.parse(response.content).map do |(summary, themes, genre, form, src, authors)|
          {
            summary: summary,
            themes: themes,
            genre: genre,
            form: form,
            authors: authors,
            src: src
          }.compact_blank
        end
      end

      def ask_chat(book)
        chat.ask([
          book.literary_form&.humanize,
          "\"#{book.title}\"",
          "(published #{book.year_published})",
          "by #{book.authors.map(&:fullname).join(', ')}"
        ].compact_blank.join(' '))
      end
    end
  end
end
