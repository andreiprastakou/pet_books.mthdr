module Admin
  class AuthorsController < AdminController
    before_action :set_author, only: %i[show edit update destroy]

    SORTING_MAP = %i[
      id
      fullname
      birth_year
      created_at
      updated_at
    ].index_by(&:to_s).freeze

    BOOKS_SORTING_MAP = %i[
      id
      title
      year_published
      wiki_popularity
      created_at
      updated_at
    ].index_by(&:to_s).freeze

    PARAMS = %i[
      fullname
      original_fullname
      reference
      birth_year
      death_year
      photo_url
    ].freeze

    def index
      @pagy, @admin_authors = pagy(
        apply_sort(
          Author.preload(:books),
          SORTING_MAP,
          defaults: { sort_by: 'id', sort_order: 'desc' }
        )
      )
    end

    def show
      @books = apply_sort(
        Book.preload(:genres, :tags).by_author(@author),
        BOOKS_SORTING_MAP,
        defaults: { sort_by: 'year_published', sort_order: 'desc' }
      ).order(id: :desc)
    end

    def new
      @author = Author.new
    end

    def edit; end

    def create
      @author = Author.new(admin_author_params)

      respond_to do |format|
        if @author.save
          format.html { redirect_to admin_author_path(@author), notice: t('notices.admin.authors.create.success') }
        else
          format.html { render :new, status: :unprocessable_content }
        end
      end
    end

    def update
      respond_to do |format|
        if @author.update(admin_author_params)
          format.html { redirect_to admin_author_path(@author), notice: t('notices.admin.authors.update.success') }
        else
          format.html { render :edit, status: :unprocessable_content }
        end
      end
    end

    def destroy
      @author.destroy!

      respond_to do |format|
        format.html do
          redirect_to admin_authors_path, status: :see_other, notice: t('notices.admin.authors.destroy.success')
        end
      end
    end

    private

    def set_author
      @author = Author.find(params.expect(:id))
    end

    def admin_author_params
      params.fetch(:author).permit(*PARAMS)
    end
  end
end
