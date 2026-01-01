module Admin
  class PublicListTypesController < AdminController
    before_action :fetch_record, only: %i[show edit update destroy]

    SORTING_MAP = %i[
      id
      name
      updated_at
      created_at
    ].index_by(&:to_s).freeze

    def index
      @public_list_types = apply_sort(
        PublicListType.all,
        SORTING_MAP,
        defaults: { sort_by: 'name', sort_order: 'asc' }
      )
    end

    def show
      @public_lists = @public_list_type.public_lists
    end

    def new
      @public_list_type = PublicListType.new
    end

    def edit; end

    def create
      @public_list_type = PublicListType.new(record_params)
      if @public_list_type.save
        redirect_to admin_public_list_type_path(@public_list_type),
                    notice: t('notices.admin.public_list_types.create.success')
      else
        render :new
      end
    end

    def update
      if @public_list_type.update(record_params)
        redirect_to admin_public_list_type_path(@public_list_type),
                    notice: t('notices.admin.public_list_types.update.success')
      else
        render :edit
      end
    end

    def destroy
      @public_list_type.destroy!
      redirect_to admin_public_list_types_path, notice: t('notices.admin.public_list_types.destroy.success')
    end

    private

    def fetch_record
      @public_list_type = PublicListType.find(params[:id])
    end

    def record_params
      params.fetch(:public_list_type).permit(:name)
    end
  end
end
