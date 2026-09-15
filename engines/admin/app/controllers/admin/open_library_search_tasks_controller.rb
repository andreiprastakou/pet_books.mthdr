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
      author = Admin::Author.find(params.require(:author_id))
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
      @task = Admin::Tasks::OpenLibraryBookSearch.find(params[:id])
    end

    def prepare_form_data
      @book = Admin::Book.includes(:external_identities).find(@task.target_id)
      assign_admin_authors!
      @search_results = sorted_search_results
      @book_open_library_ids = @book.external_identities.open_library.filter_map(&:external_id).to_set
      @author_identities_by_olid = author_identities_by_olid
    end

    def assign_admin_authors!
      author_ids = @book.book_authors.map(&:author_id)
      authors_by_id = Admin::Author.where(id: author_ids).preload(:external_identities).index_by(&:id)
      @book.association(:authors).target = author_ids.filter_map { |id| authors_by_id[id] }
    end

    def sorted_search_results
      book_year = @book.year_published.to_i
      Array(@task.fetched_data_normalized).sort_by do |result|
        year = result.is_a?(Hash) ? result['first_publish_year'].to_i : 0
        (year - book_year).abs
      end
    end

    def author_identities_by_olid
      author_olids = @search_results.flat_map { |result| result_author_ids(result) }
                                    .filter_map { |key| Admin::ExternalLinkBuilders::OpenLibrary::Author.normalize_id(key) }
                                    .uniq
      return {} if author_olids.empty?

      Admin::ExternalIdentity.open_library
                      .where(owner_type: ::Author.name, external_id: author_olids)
                      .includes(:owner)
                      .index_by(&:external_id)
    end

    def result_author_ids(result)
      return [] unless result.is_a?(Hash)

      authors = result['authors']
      return [] unless authors.is_a?(Array)

      authors.filter_map { |author| author['external_id'] if author.is_a?(Hash) }
    end
  end
end
