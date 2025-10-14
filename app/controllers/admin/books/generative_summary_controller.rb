module Admin
  module Books
    class GenerativeSummaryController < AdminController
      before_action :ensure_task_fetched, only: :show

      def show
        fetch_task
        fetch_book
        @form = Forms::BookForm.new(@book)
        @summaries = @task.fetched_data.map(&:symbolize_keys)
        @all_themes = @summaries.flat_map { |s| s[:themes].split(/,\s?/) }.uniq
      end

      def create
        fetch_book
        task = Admin::BookSummaryTask.setup(@book)
        Admin::DataFetchJob.perform_later(task.id)
        redirect_to admin_book_path(@book), notice: t('notices.admin.generative_summary.create.success')
      end

      def reject
        fetch_task
        @task.rejected!
        next_task = Admin::BookSummaryTask.where(status: :fetched).order(created_at: :asc).first
        if next_task.present?
          redirect_to admin_book_generative_summary_path(next_task.book, task_id: next_task.id),
                      notice: t('notices.admin.generative_summary.reject.success')
        else
          redirect_to admin_feed_path, notice: t('notices.admin.generative_summary.reject.nothing_else')
        end
      end

      def verify
        fetch_task
        @task.verified!
        head :ok
      end

      private

      def fetch_book
        @book = Book.preload(:genres, tag_connections: :tag).find(params[:book_id])
      end

      def fetch_task
        @task = Admin::BookSummaryTask.find(params[:task_id])
      end

      def ensure_task_fetched
        fetch_task
        redirect_to admin_data_fetch_task_path(@task), error: 'Task has not fetched data yet' unless @task.fetched?
      end
    end
  end
end
