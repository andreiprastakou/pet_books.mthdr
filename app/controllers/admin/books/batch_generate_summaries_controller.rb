module Admin
  module Books
    class BatchGenerateSummariesController < AdminController
      def create
        books =fetch_books
        books.each do |book|
          next unless book.needs_data_fetch?

          task = Admin::BookSummaryTask.setup(book)
          Admin::DataFetchJob.perform_later(task.id)
        end

        redirect_back(fallback_location: admin_books_path, notice: t('notices.admin.books_batch_generate_summaries.success'))
      end

      private

      def fetch_books
        @books = Book.where(id: params[:book_ids]).preload(:generative_summary_tasks)
      end
    end
  end
end
