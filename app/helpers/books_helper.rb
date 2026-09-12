# frozen_string_literal: true

module BooksHelper
  def book_cover_design(book)
    book.genres.first&.genre&.cover_design || default_book_cover_design || raise('No default cover design!')
  end

  def default_book_cover_design
    @default_book_cover_design ||= CoverDesign.default
  end

  def cover_background_style(palette_id)
    CoverPalettes.background_css_for_id(palette_id)
  end
end
