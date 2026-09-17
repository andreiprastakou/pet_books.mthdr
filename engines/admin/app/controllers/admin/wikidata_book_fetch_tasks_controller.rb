module Admin
  class WikidataBookFetchTasksController < AdminController
    before_action :fetch_task

    def edit
      prepare_form_data
    end

    def apply_year
      @task.apply_year!(params[:year])
      redirect_to edit_admin_wikidata_book_fetch_task_path(@task),
                  notice: t('notices.admin.wikidata_book_fetch_tasks.apply_year.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    def apply_literary_form
      @task.apply_literary_form!(params.require(:literary_form))
      redirect_to edit_admin_wikidata_book_fetch_task_path(@task),
                  notice: t('notices.admin.wikidata_book_fetch_tasks.apply_literary_form.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    def add_identity
      @task.add_identity!(params.require(:external_resource), params.require(:external_id))
      redirect_to edit_admin_wikidata_book_fetch_task_path(@task),
                  notice: t('notices.admin.wikidata_book_fetch_tasks.add_identity.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    def add_author_identity
      author = Admin::Author.find(params.require(:author_id))
      @task.add_author_identity!(params.require(:entity_id), author: author)
      redirect_to edit_admin_wikidata_book_fetch_task_path(@task),
                  notice: t('notices.admin.wikidata_book_fetch_tasks.add_author_identity.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid,
           ActiveRecord::RecordNotFound => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    def add_genre_identity
      genre = resolve_genre!
      @task.add_genre_identity!(params.require(:entity_id), genre: genre)
      redirect_to edit_admin_wikidata_book_fetch_task_path(@task),
                  notice: t('notices.admin.wikidata_book_fetch_tasks.add_genre_identity.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid,
           ActiveRecord::RecordNotFound => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    def add_series_identity
      series = resolve_series!
      @task.add_series_identity!(params.require(:entity_id), series: series)
      redirect_to edit_admin_wikidata_book_fetch_task_path(@task),
                  notice: t('notices.admin.wikidata_book_fetch_tasks.add_series_identity.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid,
           ActiveRecord::RecordNotFound => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    def add_link
      link = @task.add_link!(params.require(:url), external_resource: params.require(:external_resource))
      notice_key = link.previously_new_record? ? :success : :updated
      redirect_to edit_admin_wikidata_book_fetch_task_path(@task),
                  notice: t("notices.admin.wikidata_book_fetch_tasks.add_link.#{notice_key}")
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    def add_wikipedia_link
      @task.add_link!(params.require(:url), external_resource: ExternalResources::WIKIPEDIA)
      redirect_to edit_admin_wikidata_book_fetch_task_path(@task),
                  notice: t('notices.admin.wikidata_book_fetch_tasks.add_wikipedia_link.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    private

    def fetch_task
      @task = Admin::Tasks::WikidataBookFetch.find(params[:id])
    end

    def prepare_form_data
      @book = @task.book
      assign_book_authors!
      @fetched_data = @task.fetched_data_normalized
      @year = Admin::Tasks::WikidataBookFetch.parse_year(@fetched_data['publication_date'])
      @external_identities = @task.applyable_external_identities
      @wikipedia_sitelinks = @task.wikipedia_sitelinks
      @other_sitelinks = @task.other_sitelinks
      @book_identity_keys = identity_keys_for(@book.external_identities)
      @book_link_urls = @book.external_links.filter_map(&:url).to_set
      @book_links_by_url = @book.external_links.index_by(&:url)
      @author_identities_by_qid = wikidata_identities_by_id(::Author.name, author_qids)
      @genre_identities_by_qid = wikidata_identities_by_id(::Genre.name, genre_qids)
      @series_identities_by_qid = wikidata_identities_by_id(::Series.name, series_qids)
    end

    def assign_book_authors!
      author_ids = @book.book_authors.map(&:author_id)
      authors_by_id = Admin::Author.where(id: author_ids).preload(:external_identities).index_by(&:id)
      @book.association(:authors).target = author_ids.filter_map { |id| authors_by_id[id] }
    end

    def resolve_genre!
      if params[:genre_id].present?
        Admin::Genre.find(params[:genre_id])
      else
        name = params[:genre_query].to_s.strip
        raise ArgumentError, 'Genre name is required' if name.blank?

        Admin::Genre.find_or_create_by!(name: Genre.normalize_name_value(name))
      end
    end

    def resolve_series!
      if params[:series_id].present?
        Admin::Series.find(params[:series_id])
      else
        name = params[:series_query].to_s.strip
        raise ArgumentError, 'Series name is required' if name.blank?

        Admin::Series.find_or_create_by!(name: name)
      end
    end

    def identity_keys_for(identities)
      identities.filter_map do |identity|
        next if identity.external_id.blank?

        [identity.external_resource.to_s, identity.external_id]
      end.to_set
    end

    def wikidata_identities_by_id(owner_type, external_ids)
      return {} if external_ids.empty?

      Admin::ExternalIdentity.wikidata
                             .where(owner_type: owner_type, external_id: external_ids)
                             .includes(:owner)
                             .index_by(&:external_id)
    end

    def author_qids
      Array(@fetched_data&.dig('authors')).filter_map do |entry|
        Admin::ExternalLinkBuilders::Wikidata.normalize_id(entry['external_id'])
      end.uniq
    end

    def genre_qids
      Array(@fetched_data&.dig('genres')).filter_map do |entry|
        Admin::ExternalLinkBuilders::Wikidata.normalize_id(entry['external_id'])
      end.uniq
    end

    def series_qids
      Array(@fetched_data&.dig('series')).filter_map do |entry|
        Admin::ExternalLinkBuilders::Wikidata.normalize_id(entry['external_id'])
      end.uniq
    end
  end
end
