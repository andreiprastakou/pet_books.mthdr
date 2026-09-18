module Admin
  module Books
    class GenerativeSummariesController < AdminController
      before_action :fetch_book, only: %i[create edit apply]
      before_action :fetch_task, only: %i[edit apply]

      def edit
        prepare_form_data
      end

      def create
        task = Admin::Tasks::AiBookFetch.setup(@book)
        Admin::DataFetchJob.perform_later(task.id)
        redirect_to admin_book_path(@book), notice: t('notices.admin.generative_summaries.create.success')
      end

      def apply
        if apply_updates
          redirect_to edit_admin_book_generative_summary_path(@book, @task),
                      notice: t('notices.admin.generative_summaries.update.success')
        else
          prepare_form_data
          render :edit, status: :unprocessable_content
        end
      end

      private

      def fetch_book
        @book = Admin::Book.preload(:genres, :descriptions, tag_connections: :tag).find(params[:book_id])
      end

      def fetch_task
        @task = Admin::Tasks::AiBookFetch.find(params[:id])
      end

      def prepare_form_data
        @summaries = @task.fetched_data.map(&:symbolize_keys)
        @all_themes = @summaries.flat_map { |s| s[:themes]&.split(/,\s?/) }.uniq.compact
        @task_description = @book.description_for_source(@task)
      end

      def apply_updates
        persist_task_updates!
        true
      rescue ActiveRecord::RecordInvalid
        false
      end

      def persist_task_updates!
        ActiveRecord::Base.transaction do
          @book.update!(admin_book_params)
          @book.upsert_description_from_source!(
            @task,
            text: description_params[:text].to_s,
            source_label: description_params[:source_label]
          )
          @task.verified!
        end
      end

      def admin_book_params
        params.fetch(:book).permit(:title, :original_title, :year_published,
                                   :literary_form, :data_filled,
                                   tag_names: [], genre_names: [], author_ids: [])
      end

      def description_params
        params.fetch(:description, {}).permit(:text, :source_label)
      end
    end
  end
end
