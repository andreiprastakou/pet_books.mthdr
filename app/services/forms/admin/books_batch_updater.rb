module Forms
  module Admin
    class BooksBatchUpdater
      attr_reader :books

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
        params.each_value do |book_params|
          book = book_params[:id].present? ? Book.find(book_params[:id]) : Book.new
          book.assign_attributes(params_for_book(book_params))
          yield book
        end
      end

      def params_for_book(book_params)
        {
          title: book_params[:title],
          original_title: book_params[:original_title],
          literary_form: book_params[:literary_form],
          year_published: book_params[:year_published],
          author_ids: book_params[:author_ids],
          goodreads_url: book_params[:goodreads_url],
          wiki_url: book_params[:wiki_url]
        }.compact
      end
    end
  end
end
