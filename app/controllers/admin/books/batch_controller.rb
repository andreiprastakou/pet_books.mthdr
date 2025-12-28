module Admin
  module Books
    class BatchController < AdminController
      def edit
        @books = Book.where(id: params[:book_ids]).preload(:authors)
        @authors = @books.flat_map(&:authors).uniq
      end

      def update
        updater = Forms::Admin::BooksBatchUpdater.new
        if apply_via_updater(updater)
          redirect_to redirect_path_after_update, notice: t('notices.admin.books_batch.updates_applied')
        else
          flash.now[:error] = t('notices.admin.books_batch.failed', errors: updater.collect_errors)
          prepare_form_data
          render :edit
        end
      end

      private

      def apply_via_updater(updater)
        updater.update(params.fetch(:batch)).tap do
          @books = updater.books
        end
      end

      def redirect_path_after_update
        author = @books.first&.authors&.first
        author.present? ? admin_author_path(author) : admin_books_path
      end

      def prepare_form_data
        @authors = @books.flat_map(&:authors).uniq
      end
    end
  end
end
