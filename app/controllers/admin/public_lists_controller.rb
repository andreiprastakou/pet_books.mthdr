module Admin
  class PublicListsController < AdminController
    before_action :fetch_public_list_type
    before_action :fetch_record, only: %i[show edit update destroy]

    BOOKS_SORTING_MAP = %i[
      id
      title
      year_published
      wiki_popularity
    ].index_by(&:to_s).freeze

    def show
      @books = apply_sort(
        @public_list.books.preload(:authors),
        BOOKS_SORTING_MAP,
        defaults: { sort_by: 'year_published', sort_order: 'desc' }
      )
    end

    def new
      @public_list = @public_list_type.public_lists.build
    end

    def edit; end

    def create
      @public_list = @public_list_type.public_lists.build(record_params)
      if @public_list.save
        redirect_to admin_public_list_type_public_list_path(@public_list_type, @public_list),
          notice: t('notices.admin.public_lists.create.success')
      else
        render :new
      end
    end

    def update
      if @public_list.update(record_params)
        redirect_to admin_public_list_type_public_list_path(@public_list_type, @public_list),
          notice: t('notices.admin.public_lists.update.success')
      else
        render :edit
      end
    end

    def destroy
      @public_list.destroy!
      redirect_to admin_public_list_type_path(@public_list_type),
        notice: t('notices.admin.public_lists.destroy.success')
    end

    private

    def fetch_public_list_type
      @public_list_type = PublicListType.find(params[:public_list_type_id])
    end

    def fetch_record
      @public_list = PublicList.find(params[:id])
    end

    def record_params
      params.fetch(:public_list).permit(:year, book_ids: [])
    end
  end
end
