module Admin
  class DataFetchJob < Admin::ApplicationJob
    queue_as :data_fetches

    def perform(data_fetch_task_id)
      task = Admin::Tasks::BaseTask.find(data_fetch_task_id)
      task.perform
    end
  end
end
