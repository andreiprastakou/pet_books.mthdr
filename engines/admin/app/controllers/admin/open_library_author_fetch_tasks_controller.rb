module Admin
  class OpenLibraryAuthorFetchTasksController < AdminController
    before_action :fetch_task

    def edit
      prepare_form_data
    end

    def apply_birth_year
      @task.apply_birth_year!(params[:year])
      redirect_to edit_admin_open_library_author_fetch_task_path(@task),
                  notice: t('notices.admin.open_library_author_fetch_tasks.apply_birth_year.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    def apply_death_year
      @task.apply_death_year!(params[:year])
      redirect_to edit_admin_open_library_author_fetch_task_path(@task),
                  notice: t('notices.admin.open_library_author_fetch_tasks.apply_death_year.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    def apply_description
      @task.apply_description!(params.require(:text))
      redirect_to edit_admin_open_library_author_fetch_task_path(@task),
                  notice: t('notices.admin.open_library_author_fetch_tasks.apply_description.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    def add_identity
      @task.add_identity!(params.require(:external_resource), params.require(:external_id))
      redirect_to edit_admin_open_library_author_fetch_task_path(@task),
                  notice: t('notices.admin.open_library_author_fetch_tasks.add_identity.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    def add_link
      link = @task.add_link!(params.require(:url), external_resource: params.require(:external_resource))
      notice_key = link.previously_new_record? ? :success : :updated
      redirect_to edit_admin_open_library_author_fetch_task_path(@task),
                  notice: t("notices.admin.open_library_author_fetch_tasks.add_link.#{notice_key}")
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    private

    def fetch_task
      @task = Admin::Tasks::OpenLibraryAuthorFetch.find(params[:id])
    end

    def prepare_form_data
      @author = @task.author
      @task_description = @author.description_for_source(@task)
      @fetched_data = @task.fetched_data_normalized
      @bio = @task.description_for_textarea
      @birth_year = Admin::Tasks::OpenLibraryAuthorFetch.parse_year(@fetched_data['birth_date'])
      @death_year = Admin::Tasks::OpenLibraryAuthorFetch.parse_year(@fetched_data['death_date'])
      @remote_ids = @task.applyable_remote_ids
      @links = @task.applyable_links
      load_author_identities_and_links
    end

    def load_author_identities_and_links
      @author_identity_keys = identity_keys_for(@author.external_identities)
      @author_links_by_url = @author.external_links.index_by(&:url)
    end

    def identity_keys_for(identities)
      identities.filter_map do |identity|
        next if identity.external_id.blank?

        [identity.external_resource.to_s, identity.external_id]
      end.to_set
    end
  end
end
