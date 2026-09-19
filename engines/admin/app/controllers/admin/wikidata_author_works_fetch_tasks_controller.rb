# frozen_string_literal: true

module Admin
  class WikidataAuthorWorksFetchTasksController < AdminController
    before_action :fetch_task

    def edit
      prepare_form_data
    end

    def apply_work
      @task.apply_work!(
        title: params.require(:title),
        year: params.require(:year),
        book_id: params[:book_id],
        entity_id: params[:entity_id]
      )
      redirect_to edit_admin_wikidata_author_works_fetch_task_path(@task),
                  notice: t('notices.admin.wikidata_author_works_fetch_tasks.apply_work.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid,
           ActiveRecord::RecordNotFound => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    private

    def fetch_task
      @task = Admin::Tasks::WikidataAuthorWorksFetch.find(params[:id])
    end

    def prepare_form_data
      @author = @task.author
      @author_books = Admin::Book.for_scope(@author.books).order(:year_published, :id)
      @rows = Admin::WikidataAuthorWorksRowsBuilder.call(
        author: @author,
        works: @task.fetched_data
      )
    end
  end
end
