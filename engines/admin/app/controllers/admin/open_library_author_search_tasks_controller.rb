module Admin
  class OpenLibraryAuthorSearchTasksController < AdminController
    before_action :fetch_task

    def edit
      prepare_form_data
    end

    def add_author_identity
      @task.add_author_identity!(params.require(:author_key))
      redirect_to edit_admin_open_library_author_search_task_path(@task),
                  notice: t('notices.admin.open_library_author_search_tasks.add_author_identity.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    private

    def fetch_task
      @task = Admin::Tasks::OpenLibraryAuthorSearch.find(params[:id])
    end

    def prepare_form_data
      @author = @task.author
    end
  end
end
