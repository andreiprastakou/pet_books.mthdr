module Admin
  class WikidataAuthorSearchTasksController < AdminController
    before_action :fetch_task

    def add_author_identity
      @task.add_author_identity!(params.require(:entity_id))
      redirect_to admin_data_fetch_task_path(@task),
                  notice: t('notices.admin.wikidata_author_search_tasks.add_author_identity.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      redirect_to admin_data_fetch_task_path(@task), flash: { error: e.message }
    end

    private

    def fetch_task
      @task = Admin::Tasks::WikidataAuthorSearch.find(params[:id])
    end
  end
end
