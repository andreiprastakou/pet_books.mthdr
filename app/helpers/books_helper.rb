# frozen_string_literal: true

module BooksHelper
  def book_cover_design(book)
    book.genres.first&.genre&.cover_design || default_book_cover_design || raise('No default cover design!')
  end

  def default_book_cover_design
    @default_book_cover_design ||= CoverDesign.default
  end
end
