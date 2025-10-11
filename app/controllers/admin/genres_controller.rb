module Admin
  class GenresController < AdminController
    before_action :set_genre, only: %i[show edit update destroy]

    SORTING_MAP = %i[
      id
      name
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

    def index
      @genres = apply_sort(
        Genre.preload(:book_genres),
        SORTING_MAP,
        defaults: { sort_by: 'id', sort_order: 'desc' }
      )
    end

    def show
      @books = apply_sort(
        @genre.books.preload(:genres, :tags, :author),
        BOOKS_SORTING_MAP,
        defaults: { sort_by: 'year_published', sort_order: 'desc' }
      )
    end

    def new
      @genre = Genre.new
    end

    def edit; end

    def create
      @genre = Genre.new(admin_genre_params)

      respond_to do |format|
        if @genre.save
          format.html { redirect_to admin_genre_path(@genre), notice: t('notices.admin.genres.create.success') }
        else
          format.html { render :new, status: :unprocessable_content }
        end
      end
    end

    def update
      respond_to do |format|
        if @genre.update(admin_genre_params)
          format.html { redirect_to admin_genre_path(@genre), notice: t('notices.admin.genres.update.success') }
        else
          format.html { render :edit, status: :unprocessable_content }
        end
      end
    end

    def destroy
      @genre.destroy!

      respond_to do |format|
        format.html do
          redirect_to admin_genres_path, status: :see_other, notice: t('notices.admin.genres.destroy.success')
        end
      end
    end

    private

    def set_genre
      @genre = ::Genre.find(params[:id])
    end

    def admin_genre_params
      params.fetch(:genre).permit(:name, :cover_design_id)
    end

    def apply_sort(scope, _sorting_map, defaults: {})
      apply_sorting_defaults(defaults)
      return super unless sorting_params[:sort_by] == 'connections_count'

      direction = sorting_params[:sort_order] == 'desc' ? :desc : :asc
      scope.left_joins(:book_genres)
           .group('genres.id')
           .order("COUNT(book_genres.id) #{direction}")
    end
  end
end
