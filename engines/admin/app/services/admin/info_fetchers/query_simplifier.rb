# frozen_string_literal: true

module Admin
  module InfoFetchers
    # Downcase and strip punctuation/diacritics while keeping letters (any script) and numbers.
    module QuerySimplifier
      private

      def simplify_query(text)
        text.to_s
            .unicode_normalize(:nfkd)
            .gsub(/\p{M}/, '')
            .downcase
            .gsub(/[^\p{L}\p{N}\s]/, ' ')
            .squeeze(' ')
            .strip
      end
    end
  end
end
