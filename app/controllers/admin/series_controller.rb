module Admin
  class SeriesController < AdminController
    before_action :set_series, only: %i[show edit update destroy]

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
      @series = apply_sort(
        Series.preload(:book_series),
        SORTING_MAP,
        defaults: { sort_by: 'id', sort_order: 'desc' }
      )
    end

    def show
      @books = apply_sort(
        @series.books.preload(:tags, :authors),
        BOOKS_SORTING_MAP,
        defaults: { sort_by: 'year_published', sort_order: 'desc' }
      )
    end

    def new
      @series = Series.new
    end

    def edit; end

    def create
      @series = Series.new(admin_series_params)

      respond_to do |format|
        if @series.save
          format.html { redirect_to admin_series_path(@series), notice: t('notices.admin.series.create.success') }
        else
          format.html { render :new, status: :unprocessable_content }
        end
      end
    end

    def update
      respond_to do |format|
        if @series.update(admin_series_params)
          format.html { redirect_to admin_series_path(@series), notice: t('notices.admin.series.update.success') }
        else
          format.html { render :edit, status: :unprocessable_content }
        end
      end
    end

    def destroy
      if @series.destroy
        redirect_to admin_series_index_path, status: :see_other, notice: t('notices.admin.series.destroy.success')
      else
        errors = @series.errors.full_messages.join(', ')
        redirect_to admin_series_path(@series),
                    status: :see_other, alert: t('notices.admin.series.destroy.failure', errors: errors)
      end
    end

    private

    def set_series
      @series = ::Series.find(params[:id])
    end

    def admin_series_params
      params.fetch(:series).permit(:name)
    end

    def apply_sort(scope, _sorting_map, defaults: {})
      apply_sorting_defaults(defaults)
      return super unless sorting_params[:sort_by] == 'books_count'

      direction = sorting_params[:sort_order] == 'desc' ? :desc : :asc
      scope.left_joins(:book_series)
           .group('series.id')
           .order("COUNT(book_series.id) #{direction}")
    end
  end
end
