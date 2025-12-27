module Admin
  module Books
    class BatchController < AdminController
      def edit
        @books = Book.where(id: params[:book_ids]).preload(:author)
        @authors = @books.map(&:author).uniq
      end

      def update
        updater = Forms::Admin::BooksBatchUpdater.new
        success = updater.update(params.fetch(:batch))
        @books = updater.books
        if success
          flash.now[:success] = t('notices.admin.books_batch.updates_applied')
          redirect_to redirect_path_after_update
        else
          flash.now[:error] = t('notices.admin.books_batch.failed', errors: updater.collect_errors)
          render :edit
        end
      end

      private

      def redirect_path_after_update
        @books.present? ? admin_author_path(@books.first.author) : admin_books_path
      end
    end
  end
end
