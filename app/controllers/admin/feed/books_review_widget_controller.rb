module Admin
  module Feed
    class BooksReviewWidgetController < AdminController
      def show
        fetch_books_to_fill
        fetch_summaries_to_verify
      end

      def request_summary
        book = Book.find(params[:book_id])
        task = Admin::BookSummaryTask.setup(book)
        Admin::DataFetchJob.perform_later(task.id)

        fetch_books_to_fill
        fetch_summaries_to_verify
        render :show
      end

      private

      def fetch_books_to_fill
        @books_to_fill = Book.not_filled.without_tasks.first(10)
      end

      def fetch_summaries_to_verify
        @summaries_to_verify = Admin::BookSummaryTask.where(status: :fetched).first(10)
      end
    end
  end
end
