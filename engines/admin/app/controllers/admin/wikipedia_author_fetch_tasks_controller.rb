module Admin
  class WikipediaAuthorFetchTasksController < AdminController
    before_action :fetch_task

    def edit
      prepare_form_data
    end

    def apply_description
      @task.apply_description!(params.require(:text))
      redirect_to edit_admin_wikipedia_author_fetch_task_path(@task),
                  notice: t('notices.admin.wikipedia_author_fetch_tasks.apply_description.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    private

    def fetch_task
      @task = Admin::Tasks::WikipediaAuthorFetch.find(params[:id])
    end

    def prepare_form_data
      @author = @task.author
      @task_description = @author.description_for_source(@task)
      @fetched_data = @task.fetched_data_normalized
      @description = @fetched_data['description']
    end
  end
end
