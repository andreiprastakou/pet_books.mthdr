module Admin
  class BooksBatchUpdater
    attr_reader :books

    PRELOADS = %i[authors book_authors external_links external_identities wiki_links book_series series].freeze

    def initialize
      @books = []
    end

    def update(updates_params, on_save: nil)
      @books = []
      all_successful = true
      Book.transaction do
        params_to_books(updates_params) do |book, book_params|
          all_successful = save_book(book, book_params, on_save) && all_successful
          @books << book
        end
        raise ActiveRecord::Rollback unless all_successful
      end
      all_successful
    end

    def collect_errors
      @books.filter_map { |book| error_summary_for(book) }.join('; ')
    end

    private

    def params_to_books(params)
      values = params.each_value.to_a
      books_by_id = load_existing_books(values)
      values.each { |book_params| yield book_from_params(book_params, books_by_id), book_params }
    end

    def save_book(book, book_params, on_save)
      return false unless book.valid? && book.save

      on_save&.call(book, book_params)
      book.errors.empty?
    end

    def book_from_params(book_params, books_by_id)
      book = if book_params[:id].present?
               books_by_id.fetch(book_params[:id].to_s)
             else
               Admin::Book.new
             end
      book.assign_attributes(params_for_book(book_params))
      book
    end

    def load_existing_books(values)
      ids = values.filter_map { |book_params| book_params[:id].presence }
      return {} if ids.empty?

      Admin::Book.where(id: ids).preload(*PRELOADS).index_by { |book| book.id.to_s }
    end

    def error_summary_for(book)
      return if book.errors.empty?

      "#{error_label_for(book)}: #{book.errors.full_messages.to_sentence}"
    end

    def error_label_for(book)
      return "Book #{book.id}" if book.persisted?

      title = book.title.to_s.strip
      title.present? ? %(New book "#{title}") : 'New book'
    end

    def params_for_book(book_params)
      {
        title: book_params[:title],
        original_title: book_params[:original_title],
        literary_form: book_params[:literary_form],
        year_published: book_params[:year_published],
        author_ids: book_params[:author_ids],
        series_ids: book_params[:series_ids],
        wiki_url: book_params[:wiki_url]
      }.compact
    end
  end
end
