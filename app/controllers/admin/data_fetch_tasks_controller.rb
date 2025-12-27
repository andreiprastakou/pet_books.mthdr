module Admin
  class DataFetchTasksController < AdminController
    before_action :fetch_task, only: %i[show reject]

    def index
      @tasks = Admin::BaseDataFetchTask.order(id: :desc)
    end

    def show; end

    def reject
      @task.rejected!
      redirect_to admin_root_path
    end

    private

    def fetch_task
      @task = Admin::BaseDataFetchTask.find(params[:id])
    end
  end
end
