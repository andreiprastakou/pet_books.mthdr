module InfoFetchers
  module Chats
    class BookSummaryWriter < InfoFetchers::Chats::BaseChat
      INSTRUCTIONS = <<~INSTRUCTIONS.freeze
        give me attributes and a summary of a given book.
        steps:
        1. search web resources for long detailed descriptions of the book - pick only ones that mention the right title and author;
        2. from two resources, collect separately:
        2.1. a short exposition of the story, including main characters, with key events, 200..400 words;
        2.2. source name;
        2.3. genre name (one of: <GENRES>);
        2.4. themes;
        2.5: literary form (one of: #{Book::STANDARD_FORMS.join(',')}).
        3. prepare output of the collected pieces and their sources;
        4. print JSON output only.
        rules:
        1. all output should be in English;
        2. output should be of format: [["SUMMARY","MAIN_THEME1,MAIN_THEME2","GENRE1","FORM","SOURCE_NAME"]].
      INSTRUCTIONS

      def ask(book)
        last_response = ask_chat(book)
        JSON.parse(last_response.content).map do |(summary, themes, genre, form, src)|
          {
            summary: summary,
            themes: themes,
            genre: genre,
            form: form,
            src: src
          }.compact_blank
        end
      rescue StandardError => e
        Rails.logger.error(e.message)
        @errors = [e]
        []
      end

      def chat
        @chat ||= Ai::Chat.start.tap do |chat|
          chat.with_instructions(INSTRUCTIONS.gsub('<GENRES>', Genre.pluck(:name).join(',')))
        end
      end

      private

      def ask_chat(book)
        chat.ask([
          book.literary_form&.humanize,
          "\"#{book.title}\"",
          "(#{book.year_published})",
          "by #{book.author.fullname}"
        ].compact_blank.join(' '))
      end
    end
  end
end
