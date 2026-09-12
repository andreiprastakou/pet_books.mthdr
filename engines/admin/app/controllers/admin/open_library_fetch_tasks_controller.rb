module Admin
  class OpenLibraryFetchTasksController < AdminController
    before_action :fetch_task

    def edit
      prepare_form_data
    end

    def add_identity
      @task.add_identity!(params.require(:external_resource), params.require(:identificator))
      redirect_to admin_data_fetch_task_path(@task),
                  notice: t('notices.admin.open_library_fetch_tasks.add_identity.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    def apply_summary
      @task.apply_summary!(params.require(:summary))
      redirect_to admin_data_fetch_task_path(@task),
                  notice: t('notices.admin.open_library_fetch_tasks.apply_summary.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    private

    def fetch_task
      @task = Admin::OpenLibraryFetchTask.find(params[:id])
    end

    def prepare_form_data
      @book = @task.book
      @fetched_data = @task.fetched_data
      @identifiers = @task.fetched_identifiers
      @description = @task.fetched_description
      @book_identity_keys = @book.external_identities.filter_map do |identity|
        next if identity.identificator.blank?

        [identity.external_resource.to_s, identity.identificator]
      end.to_set
    end
  end
end
