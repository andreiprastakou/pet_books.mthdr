module Admin
  module Books
    class GenerativeSummariesController < AdminController
      before_action :fetch_book, only: %i[create edit update]
      before_action :fetch_task, only: %i[edit update reject]
      before_action :ensure_task_fetched, only: :edit

      def create
        task = Admin::BookSummaryTask.setup(@book)
        Admin::DataFetchJob.perform_later(task.id)
        redirect_to admin_book_path(@book), notice: t('notices.admin.generative_summaries.create.success')
      end

      def edit
        @form = Forms::BookForm.new(@book)
        prepare_form_data
      end

      def update
        @form = Forms::BookForm.new(@book)
        if @form.update(admin_book_params)
          @task.verified! if params[:summary_verified]
          redirect_to admin_book_path(@book), notice: t('notices.admin.generative_summaries.update.success')
        else
          prepare_form_data
          render :edit, status: :unprocessable_content
        end
      end

      def reject
        @task.rejected!
        next_task = Admin::BookSummaryTask.where(status: :fetched).order(created_at: :asc).first
        if next_task.present?
          redirect_to admin_book_generative_summary_path(next_task.book, task_id: next_task.id),
                      notice: t('notices.admin.generative_summaries.reject.success')
        else
          redirect_to admin_root_path, notice: t('notices.admin.generative_summaries.reject.nothing_else')
        end
      end

      private

      def fetch_book
        @book = Book.preload(:genres, tag_connections: :tag).find(params[:book_id])
      end

      def fetch_task
        @task = Admin::BookSummaryTask.find(params[:id])
      end

      def prepare_form_data
        @summaries = @task.fetched_data.map(&:symbolize_keys)
        @all_themes = @summaries.flat_map { |s| s[:themes].split(/,\s?/) }.uniq
      end

      def ensure_task_fetched
        redirect_to admin_data_fetch_task_path(@task), error: 'Task has not fetched data yet' unless @task.fetched?
      end

      def admin_book_params
        params.fetch(:book).permit(:title, :original_title, :year_published, :author_id,
                                   :summary, :summary_src, :literary_form, :data_filled,
                                   tag_names: [], genre_names: [])
      end
    end
  end
end
