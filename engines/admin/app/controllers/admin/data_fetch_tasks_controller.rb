module Admin
  class DataFetchTasksController < AdminController
    before_action :fetch_task, only: %i[show verify reject]

    def index
      @tasks = Admin::BaseDataFetchTask.order(id: :desc)
    end

    def show; end

    def verify
      @task.verified!
      redirect_to admin_root_path, notice: status_change_notice
    end

    def reject
      @task.rejected!
      redirect_to admin_root_path, notice: status_change_notice
    end

    private

    def fetch_task
      @task = Admin::BaseDataFetchTask.find(params[:id])
    end

    def status_change_notice
      t('notices.admin.data_fetch_tasks.status_change.success', id: @task.id, status: @task.status)
    end
  end
end
