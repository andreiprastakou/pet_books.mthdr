module Admin
  class DataFetchTasksController < AdminController
    before_action :fetch_task, only: %i[show verify reject]

    INDEX_PAGE_SIZE = 100

    def index
      @pagy, @tasks = pagy(filtered_tasks.order(id: :desc), limit: INDEX_PAGE_SIZE)
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

    def filtered_tasks
      scope = Admin::Tasks::BaseTask.all
      scope = scope.where(type: params[:type]) if task_type_filter.present?
      scope = scope.where(status: params[:status]) if task_status_filter.present?
      scope
    end

    def task_type_filter
      type = params[:type].presence
      type if Admin::Tasks::BaseTask::TASK_TYPES.include?(type)
    end

    def task_status_filter
      status = params[:status].presence
      status if Admin::Tasks::BaseTask.statuses.key?(status)
    end

    def fetch_task
      @task = Admin::Tasks::BaseTask.find(params[:id])
    end

    def status_change_notice
      t('notices.admin.data_fetch_tasks.status_change.success', id: @task.id, status: @task.status)
    end
  end
end
