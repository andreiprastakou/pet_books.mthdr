module Admin
  module Books
    class GenerativeSummariesController < AdminController
      before_action :fetch_book, only: %i[create edit apply]
      before_action :fetch_task, only: %i[edit apply]

      def edit
        @form = Forms::BookForm.new(@book)
        prepare_form_data
      end

      def create
        task = Admin::BookSummaryTask.setup(@book)
        Admin::DataFetchJob.perform_later(task.id)
        redirect_to admin_book_path(@book), notice: t('notices.admin.generative_summaries.create.success')
      end

      def apply
        @form = Forms::BookForm.new(@book)
        if @form.update(admin_book_params)
          @task.verified!
          redirect_to admin_book_path(@book), notice: t('notices.admin.generative_summaries.update.success')
        else
          prepare_form_data
          render :edit, status: :unprocessable_content
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
        @all_themes = @summaries.flat_map { |s| s[:themes]&.split(/,\s?/) }.uniq.compact
      end

      def admin_book_params
        params.fetch(:book).permit(:title, :original_title, :year_published, :author_id,
                                   :summary, :summary_src, :literary_form, :data_filled,
                                   tag_names: [], genre_names: [])
      end
    end
  end
end
