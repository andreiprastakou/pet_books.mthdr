module Admin
  module Authors
    class OpenLibraryFetchesController < AdminController
      before_action :fetch_author
      before_action :fetch_external_identity

      def create
        task = Admin::Tasks::OpenLibraryAuthorFetch.setup(@external_identity)
        task.enqueue_for_processing!
        redirect_to admin_author_path(@author), notice: t('notices.admin.open_library_fetches.create.success')
      end

      private

      def fetch_author
        @author = Admin::Author.find(params[:author_id])
      end

      def fetch_external_identity
        @external_identity = @author.external_identities.open_library.find(params[:external_identity_id])
      end
    end
  end
end
