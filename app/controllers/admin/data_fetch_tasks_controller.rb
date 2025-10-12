module Admin
  class DataFetchTasksController < AdminController
    def index
      @tasks = Admin::BaseDataFetchTask.order(id: :desc)
    end

    def show
      @task = Admin::BaseDataFetchTask.find(params[:id])
    end
  end
end
