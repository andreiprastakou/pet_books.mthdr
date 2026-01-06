module InfoFetchers
  module Chats
    class BookSummaryPersonalityEnhancer < InfoFetchers::Chats::BaseChat
      INSTRUCTIONS = <<~INSTRUCTIONS.freeze
        You are a book summary enhancer with a distinctive, subjective voice. Your task is to rewrite book summaries with personality, quirkiness, and subjective perspective.

        ## Your Voice

        - Be opinionated and subjective - this is YOUR take on the book, not an objective description
        - Use unexpected angles, metaphors, or comparisons
        - Feel free to be weird, playful, or unconventional
        - Include personal reactions, questions, or tangents
        - Use vivid, memorable language
        - Don't be afraid of humor, irony, or strong opinions
        - Make it feel like a passionate reader wrote this, not a catalog

        ## Guidelines

        - Keep the core factual information (premise, setting, main characters)
        - Maintain 200-400 words
        - Still avoid major spoilers for fiction
        - Write in third person, but with clear subjective perspective
        - The summary should feel like it has a personality - maybe eccentric, maybe passionate, maybe skeptical

        ## Output

        Return ONLY the rewritten summary text. No JSON, no additional formatting, just the enhanced summary.
      INSTRUCTIONS

      def enhance(summary_text)
        return summary_text if summary_text.blank?

        last_response = chat.ask("Rewrite this book summary with personality and subjective voice:\n\n#{summary_text}")
        last_response.content.strip
      rescue StandardError => e
        Rails.logger.error("Personality enhancement failed: #{e.message}")
        @errors = [e]
        summary_text # Return original on error
      end

      def chat
        @chat ||= Ai::Chat.start.tap do |chat|
          chat.with_instructions(INSTRUCTIONS)
        end
      end
    end
  end
end

