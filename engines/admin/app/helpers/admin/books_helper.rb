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

      label = 'wiki'
      label += " (#{number_with_delimiter(book.wiki_popularity)})" if book.wiki_popularity.positive?
      content_tag(:span, external_link_to(label, book.wiki_url), class: 'text-muted')
    end

    def book_summary_icon(book)
      return if book.summary.blank?

      content_tag(:span, 'i', class: 'badge bg-secondary', title: book.summary)
    end

    def button_to_generate_books_summaries(books)
      books = books.select(&:needs_data_fetch?)
      return if books.empty?

      button_to "AI generate #{pluralize(books.count, 'summary')}",
                admin_books_batch_generate_summaries_path(book_ids: books.pluck(:id)),
                method: :post, class: 'btn btn-primary me-1'
    end
  end
end
