module Admin
  module BooksHelper
    def book_label_for_badges(book)
      "#{book.title} by #{book.authors.map(&:fullname).join(', ')}, #{book.year_published}"
    end

    def book_title_marked_for_data_fetch(book)
      book = Admin::Book.cast(book)
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
      text = book.primary_description&.text
      return if text.blank?

      content_tag(:span, 'i', class: 'badge bg-secondary', title: text)
    end

    def button_to_generate_books_summaries(books, label: nil, **options)
      books = Admin::Book.cast_collection(books).select(&:needs_data_fetch?)
      return if books.empty?

      label ||= "AI generate #{pluralize(books.count, 'summary')}"
      label = format(label, count: books.count) if label.include?('%{count}')

      button_to label,
                admin_books_batch_generate_summaries_path(book_ids: books.pluck(:id)),
                **{ method: :post, class: 'btn btn-primary me-1' }.merge(options)
    end
  end
end
