# frozen_string_literal: true

module BooksHelper
  def book_cover_design(book)
    book.genres.first&.genre&.cover_design || default_book_cover_design
  end

  def default_book_cover_design
    @default_book_cover_design ||= CoverDesign.default || raise('No default cover design!')
  end
end
