module Admin
  module Feed
    class BooksReviewWidgetController < AdminController
      def show
        fetch_view_data
      end

      def request_summary
        book = Book.find(params[:book_id])
        task = Admin::BookSummaryTask.setup(book)
        Admin::DataFetchJob.perform_later(task.id)

        fetch_view_data
        render :show
      end

      private

      def fetch_view_data
        books_to_fill_scope = Book.preload(:authors).not_filled.without_tasks
        @books_to_fill = books_to_fill_scope.first(5)
        @books_to_fill_count = books_to_fill_scope.count

        summaries_to_verify_scope = Admin::BookSummaryTask.where(status: :fetched)
        @summaries_to_verify = summaries_to_verify_scope.first(5)
        @summaries_to_verify_count = summaries_to_verify_scope.count
      end
    end
  end
end
