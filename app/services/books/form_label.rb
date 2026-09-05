# frozen_string_literal: true

module Books
  # Renders a book's genres and literary form as a short readable phrase,
  # e.g. "a fantasy novel" or "an epic, horror and mystery short story".
  class FormLabel
    FORM_NAMES = {
      'novel' => 'novel',
      'novella' => 'novella',
      'short' => 'short story',
      'short_story' => 'short story',
      'poem' => 'poem',
      'play' => 'play',
      'comics' => 'comic',
      'non_fiction' => 'non-fiction work',
    }.freeze

    GENRE_NAMES = {
      'scifi' => 'sci-fi',
    }.freeze

    def self.call(book)
      new(book).to_s
    end

    def initialize(book)
      @book = book
    end

    def to_s
      return '' if body.blank?

      "#{article} #{body}"
    end

    private

    attr_reader :book

    def article
      body.match?(/\A[aeiou]/i) ? 'an' : 'a'
    end

    def body
      [genres_summary, form_name].compact_blank.join(' ')
    end

    def genres_summary
      genre_names = book.genres.map do |book_genre|
        humanize_codified(GENRE_NAMES.fetch(book_genre.genre_name, book_genre.genre_name))
      end
      return if genre_names.empty?

      genre_names.to_sentence
    end

    def form_name
      return if book.literary_form.blank?

      FORM_NAMES.fetch(book.literary_form) { humanize_codified(book.literary_form) }
    end

    def humanize_codified(value)
      value.to_s.tr('_', ' ')
    end
  end
end
