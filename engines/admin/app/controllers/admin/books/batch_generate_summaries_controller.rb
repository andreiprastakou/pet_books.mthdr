module Admin
  module Books
    class BatchGenerateSummariesController < AdminController
      before_action :fetch_books, only: :create
      before_action :check_books_presence, only: :create

      def create
        @books.each do |book|
          task = Admin::BookSummaryTask.setup(book)
          Admin::DataFetchJob.perform_later(task.id)
        end

        redirect_back(fallback_location: admin_books_path,
                      notice: t('notices.admin.books_batch_generate_summaries.success'))
      end

      private

      def fetch_books
        @books = Book.where(id: params[:book_ids]).preload(:generative_summary_tasks).select(&:needs_data_fetch?)
      end

      def check_books_presence
        return if @books.present?

        redirect_back(fallback_location: admin_books_path,
                      notice: t('notices.admin.books_batch_generate_summaries.nothing_to_fetch'))
      end
    end
  end
end
