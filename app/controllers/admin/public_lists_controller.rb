module Admin
  class PublicListsController < AdminController
    before_action :fetch_public_list_type
    before_action :fetch_record, only: %i[show edit update destroy]

    BOOKS_SORTING_MAP = {
      'role' => 'role',
      'title' => 'books.title',
      'year_published' => 'books.year_published',
      'wiki_popularity' => 'books.wiki_popularity'
    }.freeze

    def show
      @book_public_lists = apply_sort(
        @public_list.book_public_lists.preload(book: %i[authors generative_summary_tasks]).includes(:book),
        BOOKS_SORTING_MAP,
        defaults: { sort_by: 'role', sort_order: 'desc' }
      )
    end

    def new
      @public_list = Admin::PublicListForm.new(public_list_type: @public_list_type)
    end

    def edit; end

    def create
      @public_list = Admin::PublicListForm.new(record_params.merge(public_list_type: @public_list_type))
      if @public_list.save
        redirect_to admin_public_list_type_public_list_path(@public_list_type, @public_list),
                    notice: t('notices.admin.public_lists.create.success')
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @public_list.update(record_params)
        redirect_to admin_public_list_type_public_list_path(@public_list_type, @public_list),
                    notice: t('notices.admin.public_lists.update.success')
      else
        render :edit, status: :unprocessable_content
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
      @public_list = Admin::PublicListForm.find(params[:id])
    end

    def record_params
      permitted = params.fetch(:public_list).permit(:year, book_public_lists_attributes: {})
      if permitted.key?(:book_public_lists_attributes)
        permitted[:book_public_lists_attributes].each do |key, book_public_list_attributes|
          permitted[:book_public_lists_attributes][key] =
            book_public_list_attributes.permit(:id, :book_id, :role, :_destroy)
        end
      end
      permitted
    end
  end
end
