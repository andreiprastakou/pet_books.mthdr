module Admin
  class BooksBatchUpdater
    attr_reader :books

    PRELOADS = %i[authors book_authors external_links wiki_links book_series series].freeze

    def initialize
      @books = []
    end

    def update(updates_params)
      @books = []
      all_successful = true
      Book.transaction do
        params_to_books(updates_params) do |book|
          all_successful = book.valid? && all_successful && book.save
          @books << book
        end
        raise ActiveRecord::Rollback unless all_successful
      end
      all_successful
    end

    def collect_errors
      @books.flat_map(&:errors).map(&:full_messages).compact_blank.join(', ')
    end

    private

    def params_to_books(params)
      values = params.each_value.to_a
      books_by_id = load_existing_books(values)

      values.each do |book_params|
        book = if book_params[:id].present?
                 books_by_id.fetch(book_params[:id].to_s)
               else
                 Admin::Book.new
               end
        book.assign_attributes(params_for_book(book_params))
        yield book
      end
    end

    def load_existing_books(values)
      ids = values.filter_map { |book_params| book_params[:id].presence }
      return {} if ids.empty?

      Admin::Book.where(id: ids).preload(*PRELOADS).index_by { |book| book.id.to_s }
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
