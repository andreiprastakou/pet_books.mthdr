module Admin
  class WikidataBookSearchTasksController < AdminController
    before_action :fetch_task

    def add_work_identity
      @task.add_work_identity!(params.require(:entity_id))
      redirect_to admin_data_fetch_task_path(@task),
                  notice: t('notices.admin.wikidata_book_search_tasks.add_work_identity.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      redirect_to admin_data_fetch_task_path(@task), flash: { error: e.message }
    end

    private

    def fetch_task
      @task = Admin::Tasks::WikidataBookSearch.find(params[:id])
    end
  end
end
