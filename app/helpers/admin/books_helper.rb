module Admin
  module BooksHelper
    def book_label_for_badges(book)
      "#{book.title} by #{book.authors.map(&:fullname).join(', ')}, #{book.year_published}"
    end

    def book_title_marked_for_data_fetch(book)
      return book.title unless book.needs_data_fetch?

      content_tag(:span, book.title, class: 'text-danger')
    end

    def book_wiki_link(book)
      return if book.wiki_url.blank?

      label = "wiki"
      label += " (#{number_with_delimiter(book.wiki_popularity)})" if book.wiki_popularity.positive?
      content_tag(:span, external_link_to(label, book.wiki_url), class: 'text-muted')
    end
  end
end
