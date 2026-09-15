module Admin
  module Books
    class OpenLibraryFetchesController < AdminController
      before_action :fetch_book
      before_action :fetch_external_identity

      def create
        task = Admin::Tasks::OpenLibraryBookFetch.setup(@external_identity)
        task.enqueue_for_processing!
        redirect_to admin_book_path(@book), notice: t('notices.admin.open_library_fetches.create.success')
      end

      private

      def fetch_book
        @book = Book.find(params[:book_id])
      end

      def fetch_external_identity
        @external_identity = @book.external_identities.open_library.find(params[:external_identity_id])
      end
    end
  end
end
