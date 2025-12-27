module Admin
  class DataFetchJob < ApplicationJob
    queue_as :data_fetches

    def perform(data_fetch_task_id)
      task = Admin::BaseDataFetchTask.find(data_fetch_task_id)
      task.perform
    end
  end
end
