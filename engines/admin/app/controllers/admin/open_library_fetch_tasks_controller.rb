module Admin
  class OpenLibraryFetchTasksController < AdminController
    before_action :fetch_task

    def edit
      prepare_form_data
    end

    def add_identity
      @task.add_identity!(params.require(:external_resource), params.require(:external_id))
      redirect_to edit_admin_open_library_fetch_task_path(@task),
                  notice: t('notices.admin.open_library_fetch_tasks.add_identity.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    def apply_summary
      @task.apply_summary!(params.require(:text))
      redirect_to edit_admin_open_library_fetch_task_path(@task),
                  notice: t('notices.admin.open_library_fetch_tasks.apply_summary.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    private

    def fetch_task
      @task = Admin::Tasks::OpenLibraryBookFetch.find(params[:id])
    end

    def prepare_form_data
      @book = @task.book
      @task_description = @book.description_for_source(@task)
      @fetched_data = @task.fetched_data_normalized
      @book_identity_keys = @book.external_identities.filter_map do |identity|
        next if identity.external_id.blank?

        [identity.external_resource.to_s, identity.external_id]
      end.to_set
    end
  end
end
