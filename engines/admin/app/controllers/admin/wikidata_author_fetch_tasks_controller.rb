module Admin
  class WikidataAuthorFetchTasksController < AdminController
    before_action :fetch_task

    def edit
      prepare_form_data
    end

    def apply_birth_year
      @task.apply_birth_year!(params[:year])
      redirect_to edit_admin_wikidata_author_fetch_task_path(@task),
                  notice: t('notices.admin.wikidata_author_fetch_tasks.apply_birth_year.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    def apply_death_year
      @task.apply_death_year!(params[:year])
      redirect_to edit_admin_wikidata_author_fetch_task_path(@task),
                  notice: t('notices.admin.wikidata_author_fetch_tasks.apply_death_year.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    def add_identity
      @task.add_identity!(params.require(:external_resource), params.require(:external_id))
      redirect_to edit_admin_wikidata_author_fetch_task_path(@task),
                  notice: t('notices.admin.wikidata_author_fetch_tasks.add_identity.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    def add_link
      link = @task.add_link!(params.require(:url), external_resource: params.require(:external_resource))
      notice_key = link.previously_new_record? ? :success : :updated
      redirect_to edit_admin_wikidata_author_fetch_task_path(@task),
                  notice: t("notices.admin.wikidata_author_fetch_tasks.add_link.#{notice_key}")
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    def add_wikipedia_link
      @task.add_link!(params.require(:url), external_resource: ExternalResources::WIKIPEDIA)
      redirect_to edit_admin_wikidata_author_fetch_task_path(@task),
                  notice: t('notices.admin.wikidata_author_fetch_tasks.add_wikipedia_link.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    private

    def fetch_task
      @task = Admin::Tasks::WikidataAuthorFetch.find(params[:id])
    end

    def prepare_form_data
      @author = @task.author
      @fetched_data = @task.fetched_data_normalized
      @birth_year = Admin::Tasks::WikidataAuthorFetch.parse_year(@fetched_data['date_of_birth'])
      @death_year = Admin::Tasks::WikidataAuthorFetch.parse_year(@fetched_data['date_of_death'])
      @external_identities = @task.applyable_external_identities
      @wikipedia_sitelinks = @task.wikipedia_sitelinks
      @other_sitelinks = @task.other_sitelinks
      @author_identity_keys = identity_keys_for(@author.external_identities)
      @author_link_urls = @author.external_links.filter_map(&:url).to_set
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
