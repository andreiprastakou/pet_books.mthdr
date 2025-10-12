module Admin
  module Books
    class GenerativeSummaryController < AdminController
      before_action :ensure_task_fetched, only: :show

      def create
        fetch_book
        task = Admin::BookSummaryTask.setup(@book)
        task.perform
        redirect_to admin_book_generative_summary_path(@book, task_id: task.id)
      end

      def show
        fetch_task
        fetch_book
        @form = Forms::BookForm.new(@book)
        @summaries = @task.fetched_data.map(&:symbolize_keys)
        @all_themes = @summaries.flat_map { |s| s[:themes].split(/,\s?/) }.uniq
      end

      private

      def fetch_book
        @book ||= Book.preload(:genres, tag_connections: :tag).find(params[:book_id])
      end

      def fetch_task
        @task ||= Admin::BookSummaryTask.find(params[:task_id])
      end

      def ensure_task_fetched
        fetch_task
        redirect_to admin_data_fetch_task_path(@task), error: 'Task has not fetched data yet' unless @task.fetched?
      end
    end
  end
end
