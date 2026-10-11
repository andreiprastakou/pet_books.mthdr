module Admin
  module Covers
    class CoverDesignsController < AdminController
      before_action :fetch_record, only: %i[edit update destroy]

      def index
        @designs = CoverDesign.order(id: :desc)
      end

      def new
        @design = CoverDesign.new
      end

      def edit; end

      def create
        @design = CoverDesign.new(record_params)

        respond_to do |format|
          if @design.save
            format.html do
              redirect_to admin_covers_cover_designs_path, notice: t('notices.admin.cover_designs.create.success')
            end
          else
            format.html { render :new, status: :unprocessable_content }
          end
        end
      end

      def update
        respond_to do |format|
          if @design.update(record_params)
            format.html do
              redirect_to admin_covers_cover_designs_path, notice: t('notices.admin.cover_designs.update.success')
            end
          else
            format.html { render :edit, status: :unprocessable_content }
          end
        end
      end

      def destroy
        destroy_record(
          @design,
          success_path: admin_covers_cover_designs_path,
          failure_path: edit_admin_covers_cover_design_path(@design),
          notice: t('notices.admin.cover_designs.destroy.success')
        )
      end

      private

      def fetch_record
        @design = CoverDesign.find(params[:id])
      end

      def record_params
        params.fetch(:cover_design)
              .permit(:name, :title_font, :author_name_font, :title_color, :author_name_color, :cover_image)
      end
    end
  end
end
