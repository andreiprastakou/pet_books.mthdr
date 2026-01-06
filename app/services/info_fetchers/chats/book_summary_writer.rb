module InfoFetchers
  module Chats
    class BookSummaryWriter < InfoFetchers::Chats::BaseChat
      INSTRUCTIONS = <<~INSTRUCTIONS.freeze
        You are tasked with extracting attributes and a summary of a given book from web resources.

        ## Steps

        1. Search web resources for detailed descriptions of the book. Only use resources that explicitly mention the correct title and author.

        2. From at least two reliable resources, collect the following information separately:
           - Summary: Write a natural, engaging book annotation (200-400 words) that reads like a professional book blurb or library catalog entry. Write in third person, flowing narrative style. Do NOT use phrases like "key events are", "main characters include", or "the story follows" - instead, weave the information naturally into the prose. For fiction works, focus on the premise, setting, and early story developments only - avoid major plot twists, endings, or significant spoilers.
           - Source name: The name/identifier of the resource
           - Genre: One genre name from the allowed list: <GENRES>
           - Themes: A comma-separated list of themes (e.g., "love, betrayal, redemption")
           - Authors: A comma-separated list of author names (e.g., "John Doe, Jane Smith")
           - Literary form: One of the following: #{Book::STANDARD_FORMS.join(', ')}

        3. Prepare the output combining all collected information.

        4. Output ONLY valid JSON, no additional text or explanation.

        ## Output Format

        Return a JSON array containing one or more arrays. Each inner array must have exactly 6 string elements in this order:
        [summary, themes, genre, form, source, authors]

        Example format:
        [["A gripping tale of adventure...", "adventure, friendship, courage", "Fiction", "novel", "Wikipedia", "John Doe, Jane Smith"]]

        ## Rules

        1. Use English for all output.
        2. Each inner array represents one resource's data.
        3. If information is missing or unclear, use an empty string "" for that field.
        4. Ensure all string values are properly JSON-escaped.
        5. Themes and authors must be comma-separated strings (no arrays).
      INSTRUCTIONS

      def ask(book, enhance_personality: true)
        last_response = ask_chat(book)
        summaries = parse_summary_from_response(last_response)

        if enhance_personality
          enhance_summaries_with_personality(summaries)
        else
          summaries
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
          "(#{book.year_published})",
          "by #{book.authors.map(&:fullname).join(', ')}"
        ].compact_blank.join(' '))
      end

      def enhance_summaries_with_personality(summaries)
        enhancer = InfoFetchers::Chats::BookSummaryPersonalityEnhancer.new
        summaries.map do |summary_data|
          if summary_data[:summary].present?
            summary_data.merge(summary: enhancer.enhance(summary_data[:summary]))
          else
            summary_data
          end
        end
      end
    end
  end
end
