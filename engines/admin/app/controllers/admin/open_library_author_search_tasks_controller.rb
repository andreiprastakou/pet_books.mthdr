module Admin
  class OpenLibraryAuthorSearchTasksController < AdminController
    before_action :fetch_task

    def add_author_identity
      @task.add_author_identity!(params.require(:author_key))
      redirect_to admin_data_fetch_task_path(@task),
                  notice: t('notices.admin.open_library_author_search_tasks.add_author_identity.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      redirect_to admin_data_fetch_task_path(@task), flash: { error: e.message }
    end

    private

    def fetch_task
      @task = Admin::Tasks::OpenLibraryAuthorSearch.find(params[:id])
    end
  end
end
