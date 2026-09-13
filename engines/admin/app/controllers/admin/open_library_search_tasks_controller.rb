module Admin
  class OpenLibrarySearchTasksController < AdminController
    before_action :fetch_task

    def edit
      prepare_form_data
    end

    def add_work_identity
      @task.add_work_identity!(params.require(:work_key))
      redirect_to admin_data_fetch_task_path(@task),
                  notice: t('notices.admin.open_library_search_tasks.add_work_identity.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    def add_author_identity
      author = Author.find(params.require(:author_id))
      @task.add_author_identity!(params.require(:author_key), author: author)
      redirect_to admin_data_fetch_task_path(@task),
                  notice: t('notices.admin.open_library_search_tasks.add_author_identity.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid,
           ActiveRecord::RecordNotFound => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    private

    def fetch_task
      @task = Admin::OpenLibrarySearchTask.find(params[:id])
    end

    def prepare_form_data
      @book = Book.includes(:external_identities, authors: :external_identities).find(@task.target_id)
      @search_results = sorted_search_results
      @book_open_library_ids = @book.external_identities.open_library.filter_map(&:external_id).to_set
      @author_identities_by_olid = author_identities_by_olid
    end

    def sorted_search_results
      book_year = @book.year_published.to_i
      Array(@task.fetched_data).sort_by do |result|
        year = result.is_a?(Hash) ? (result['first_publish_year'] || result[:first_publish_year]).to_i : 0
        (year - book_year).abs
      end
    end

    def author_identities_by_olid
      author_olids = @search_results.flat_map { |result| result_author_keys(result) }
                                    .filter_map { |key| ExternalLinks::OpenLibrary::Author.normalize_id(key) }
                                    .uniq
      return {} if author_olids.empty?

      ExternalIdentity.open_library
                      .where(owner_type: Author.name, external_id: author_olids)
                      .includes(:owner)
                      .index_by(&:external_id)
    end

    def result_author_keys(result)
      return [] unless result.is_a?(Hash)

      Array(result['author_key'] || result[:author_key])
    end
  end
end
