module Admin
  class LibraryThingBookSearchTasksController < AdminController
    before_action :fetch_task

    def edit
      prepare_form_data
    end

    def add_work_link
      @task.add_work_link!(params.require(:url))
      redirect_to edit_admin_library_thing_book_search_task_path(@task),
                  notice: t('notices.admin.library_thing_book_search_tasks.add_work_link.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    private

    def fetch_task
      @task = Admin::Tasks::LibraryThingBookSearch.find(params[:id])
    end

    def prepare_form_data
      @book = @task.book
    end
  end
end
