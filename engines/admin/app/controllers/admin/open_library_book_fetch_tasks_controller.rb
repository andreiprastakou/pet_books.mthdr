module Admin
  # rubocop:disable-next Metrics/ClassLength
  class OpenLibraryBookFetchTasksController < AdminController
    before_action :fetch_task

    def edit
      prepare_form_data
    end

    def add_identity
      @task.add_identity!(params.require(:external_resource), params.require(:external_id))
      redirect_to edit_admin_open_library_book_fetch_task_path(@task),
                  notice: t('notices.admin.open_library_book_fetch_tasks.add_identity.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    def add_author_identity
      author = Admin::Author.find(params.require(:author_id))
      @task.add_author_identity!(params.require(:author_key), author: author)
      redirect_to edit_admin_open_library_book_fetch_task_path(@task),
                  notice: t('notices.admin.open_library_book_fetch_tasks.add_author_identity.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid,
           ActiveRecord::RecordNotFound => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    def add_genre_identity
      genre = Admin::Genre.find(params.require(:genre_id))
      @task.add_genre_identity!(params.require(:genre_key), genre: genre)
      redirect_to edit_admin_open_library_book_fetch_task_path(@task),
                  notice: t('notices.admin.open_library_book_fetch_tasks.add_genre_identity.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid,
           ActiveRecord::RecordNotFound => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    def add_series_identity
      series = Admin::Series.find(params.require(:series_id))
      @task.add_series_identity!(params.require(:series_key), series: series)
      redirect_to edit_admin_open_library_book_fetch_task_path(@task),
                  notice: t('notices.admin.open_library_book_fetch_tasks.add_series_identity.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid,
           ActiveRecord::RecordNotFound => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    def apply_summary
      @task.apply_summary!(params.require(:text))
      redirect_to edit_admin_open_library_book_fetch_task_path(@task),
                  notice: t('notices.admin.open_library_book_fetch_tasks.apply_summary.success')
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    def add_link
      link = @task.add_link!(params.require(:url), external_resource: params.require(:external_resource))
      notice_key = link.previously_new_record? ? :success : :updated
      redirect_to edit_admin_open_library_book_fetch_task_path(@task),
                  notice: t("notices.admin.open_library_book_fetch_tasks.add_link.#{notice_key}")
    rescue ArgumentError, ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
      flash.now[:error] = e.message
      prepare_form_data
      render :edit, status: :unprocessable_content
    end

    private

    def fetch_task
      @task = Admin::Tasks::OpenLibraryBookFetch.find(params[:id])
    end

    def prepare_form_data
      @book = @task.book
      assign_book_associations!
      @task_description = @book.description_for_source(@task)
      @fetched_data = @task.fetched_data_normalized
      @description = @fetched_data['description']
      @links = @task.applyable_links
      load_book_identities_and_links
      load_open_library_identities
    end

    def load_book_identities_and_links
      @book_identity_keys = identity_keys_for(@book.external_identities)
      @book_links_by_url = @book.external_links.index_by(&:url)
    end

    def load_open_library_identities
      @author_identities_by_olid = open_library_identities_by_id(::Author.name, author_olids)
      @genre_identities_by_olid = open_library_identities_by_id(::Genre.name, genre_olids)
      @series_identities_by_olid = open_library_identities_by_id(::Series.name, series_olids)
    end

    def assign_book_associations!
      assign_book_authors!
      assign_book_genres!
      assign_book_series!
    end

    def assign_book_authors!
      author_ids = @book.book_authors.map(&:author_id)
      authors_by_id = Admin::Author.where(id: author_ids).preload(:external_identities).index_by(&:id)
      @book.association(:authors).target = author_ids.filter_map { |id| authors_by_id[id] }
    end

    def assign_book_genres!
      genre_ids = @book.genres.map(&:genre_id)
      @book_genres = Admin::Genre.where(id: genre_ids).preload(:external_identities).to_a
    end

    def assign_book_series!
      series_ids = @book.book_series.map(&:series_id)
      series_by_id = Admin::Series.where(id: series_ids).preload(:external_identities).index_by(&:id)
      @book.association(:series).target = series_ids.filter_map { |id| series_by_id[id] }
      @book_series = @book.series.to_a
    end

    def identity_keys_for(identities)
      identities.filter_map do |identity|
        next if identity.external_id.blank?

        [identity.external_resource.to_s, identity.external_id]
      end.to_set
    end

    def open_library_identities_by_id(owner_type, external_ids)
      return {} if external_ids.empty?

      Admin::ExternalIdentity.open_library
                             .where(owner_type: owner_type, external_id: external_ids)
                             .includes(:owner)
                             .index_by(&:external_id)
    end

    def author_olids
      Array(@fetched_data&.dig('authors')).filter_map do |entry|
        Admin::ExternalLinkBuilders::OpenLibrary::Author.normalize_id(entry['external_id'])
      end.uniq
    end

    def genre_olids
      Array(@fetched_data&.dig('genres')).filter_map do |entry|
        Admin::Tasks::OpenLibraryBookFetch.normalize_open_library_key(entry['external_id'])
      end.uniq
    end

    def series_olids
      Array(@fetched_data&.dig('series')).filter_map do |entry|
        Admin::Tasks::OpenLibraryBookFetch.normalize_open_library_key(entry['external_id'])
      end.uniq
    end
  end
end
