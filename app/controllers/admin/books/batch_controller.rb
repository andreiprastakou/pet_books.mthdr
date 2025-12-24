module Admin
  module Books
    class BatchController < AdminController
      def update
        if apply_updates
          flash.now[:success] = t('notices.admin.books_batch.updates_applied')
          redirect_to @books.present? ? admin_author_path(@books.first.author) : admin_books_path
        else
          flash.now[:error] = t('notices.admin.books_batch.failed', errors: collect_errors(@books))
          render :edit
        end
      end

      private

      def apply_updates
        @books = []
        all_successful = true
        Book.transaction do
          params_to_books do |book|
            all_successful = book.valid? && all_successful && book.save
            @books << book
          end
          raise ActiveRecord::Rollback unless all_successful
        end
        all_successful
      end

      def params_to_books
        params.fetch(:batch).each_value do |book_params|
          book = book_params[:id].present? ? Book.find(book_params[:id]) : Book.new
          book.assign_attributes(params_for_book(book_params))
          yield book
        end
      end

      def update_book(book, book_params)
        book.update!(params_for_book(book_params))
      end

      def params_for_book(book_params)
        {
          title: book_params[:title],
          original_title: book_params[:original_title],
          literary_form: book_params[:literary_form],
          year_published: book_params[:year_published],
          author_id: book_params[:author_id],
          goodreads_url: book_params[:goodreads_url],
          wiki_url: book_params[:wiki_url]
        }.compact
      end

      def collect_errors(books)
        books.flat_map(&:errors).map(&:full_messages).compact_blank.join(', ')
      end
    end
  end
end
