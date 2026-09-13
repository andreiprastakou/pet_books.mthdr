module Admin
  module Books
    class ExternalIdentitiesController < AdminController
      before_action :fetch_book
      before_action :fetch_external_identity, only: %i[show edit update destroy]

      PARAMS = %i[
        external_resource
        external_id
      ].freeze

      def show; end


      def new
        @external_identity = @book.external_identities.new
      end

      def edit; end

      def create
        @external_identity = @book.external_identities.new(record_params)
        success = @external_identity.save
        Admin::ExternalIdentityIntroductor.call(@external_identity) if success

        respond_to do |format|
          if success
            format.html do
              redirect_to admin_book_external_identity_path(@book, @external_identity),
                          notice: t('notices.admin.external_identities.create.success')
            end
          else
            format.html { render :new, status: :unprocessable_content }
          end
        end
      end

      def update
        success = @external_identity.update(record_params)
        Admin::ExternalIdentityIntroductor.call(@external_identity) if success

        respond_to do |format|
          if success
            format.html do
              redirect_to admin_book_external_identity_path(@book, @external_identity),
                          notice: t('notices.admin.external_identities.update.success')
            end
          else
            format.html { render :edit, status: :unprocessable_content }
          end
        end
      end


      def destroy
        @external_identity.destroy!

        respond_to do |format|
          format.html do
            redirect_to admin_book_path(@book), status: :see_other,
                                               notice: t('notices.admin.external_identities.destroy.success')
          end
        end
      end

      private

      def fetch_book
        @book = Book.find(params[:book_id])
      end

      def fetch_external_identity
        @external_identity = @book.external_identities.find(params[:id])
      end

      def record_params
        params.fetch(:external_identity).permit(*PARAMS)
      end
    end
  end
end
