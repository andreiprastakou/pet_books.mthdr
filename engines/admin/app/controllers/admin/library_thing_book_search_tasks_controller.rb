module Admin
  class LibraryThingBookSearchTasksController < AdminController
    before_action :fetch_task

    def add_work_link
      @task.add_work_link!(params.require(:url))
      redirect_to admin_data_fetch_task_path(@task),
                  notice: t('notices.admin.library_thing_book_search_tasks.add_work_link.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      redirect_to admin_data_fetch_task_path(@task), flash: { error: e.message }
    end

    private

    def fetch_task
      @task = Admin::Tasks::LibraryThingBookSearch.find(params[:id])
    end
  end
end
