module Admin
  class WikipediaBookFetchTasksController < AdminController
    before_action :fetch_task

    def edit
      prepare_form_data
    end

    def apply_summary
      @task.apply_summary!(params.require(:text))
      redirect_to edit_admin_wikipedia_book_fetch_task_path(@task),
                  notice: t('notices.admin.wikipedia_book_fetch_tasks.apply_summary.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    private

    def fetch_task
      @task = Admin::Tasks::WikipediaBookFetch.find(params[:id])
    end

    def prepare_form_data
      @book = @task.book
      @task_description = @book.description_for_source(@task)
      @fetched_data = @task.fetched_data_normalized
      @description = @fetched_data['description']
    end
  end
end
