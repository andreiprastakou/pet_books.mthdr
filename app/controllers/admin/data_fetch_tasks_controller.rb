module Admin
  class DataFetchTasksController < AdminController
    before_action :fetch_task, only: %i[show verify reject]

    def index
      @tasks = Admin::BaseDataFetchTask.order(id: :desc)
    end

    def show
    end

    def verify
      @task.verified!
    end

    def reject
      @task.rejected!
    end

    private

    def fetch_task
      @task = Admin::BaseDataFetchTask.find(params[:id])
    end
  end
end
