module Admin
  class CollectionsController < AdminController
    before_action :set_collection, only: %i[show edit update destroy]

    SORTING_MAP = %i[
      id
      name
      year_published
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
      @collections = apply_sort(
        Collection.preload(:book_collections),
        SORTING_MAP,
        defaults: { sort_by: 'id', sort_order: 'desc' }
      )
    end

    def show
      @books = apply_sort(
        @collection.books.preload(:tags, :authors),
        BOOKS_SORTING_MAP,
        defaults: { sort_by: 'year_published', sort_order: 'desc' }
      )
    end

    def new
      @collection = Collection.new
    end

    def edit; end

    def create
      @collection = Collection.new(admin_collection_params)

      respond_to do |format|
        if @collection.save
          format.html do
            redirect_to admin_collection_path(@collection), notice: t('notices.admin.collections.create.success')
          end
        else
          format.html { render :new, status: :unprocessable_content }
        end
      end
    end

    def update
      respond_to do |format|
        if @collection.update(admin_collection_params)
          format.html do
            redirect_to admin_collection_path(@collection),
                        notice: t('notices.admin.collections.update.success')
          end
        else
          format.html { render :edit, status: :unprocessable_content }
        end
      end
    end

    def destroy
      if @collection.destroy
        redirect_to admin_collections_path, status: :see_other, notice: t('notices.admin.collections.destroy.success')
      else
        errors = @collection.errors.full_messages.join(', ')
        redirect_to admin_collection_path(@collection),
                    status: :see_other, alert: t('notices.admin.collections.destroy.failure', errors: errors)
      end
    end

    private

    def set_collection
      @collection = ::Collection.find(params[:id])
    end

    def admin_collection_params
      params.fetch(:collection).permit(:name, :year_published, book_ids: [])
    end

    def apply_sort(scope, _sorting_map, defaults: {})
      apply_sorting_defaults(defaults)
      return super unless sorting_params[:sort_by] == 'books_count'

      direction = sorting_params[:sort_order] == 'desc' ? :desc : :asc
      scope.left_joins(:book_collections)
           .group('collections.id')
           .order("COUNT(book_collections.id) #{direction}")
    end
  end
end
