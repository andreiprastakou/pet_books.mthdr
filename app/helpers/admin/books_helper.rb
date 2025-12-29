module Admin
  module BooksHelper
    def book_label_for_badges(book)
      "#{book.title} by #{book.authors.map(&:fullname).join(', ')}, #{book.year_published}"
    end
  end
end
