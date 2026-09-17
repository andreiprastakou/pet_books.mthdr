module Admin
  class WikidataBookSearchTasksController < AdminController
    before_action :fetch_task

    def edit
      prepare_form_data
    end

    def add_work_identity
      @task.add_work_identity!(params.require(:entity_id))
      redirect_to edit_admin_wikidata_book_search_task_path(@task),
                  notice: t('notices.admin.wikidata_book_search_tasks.add_work_identity.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    private

    def fetch_task
      @task = Admin::Tasks::WikidataBookSearch.find(params[:id])
    end

    def prepare_form_data
      @book = @task.book
    end
  end
end
