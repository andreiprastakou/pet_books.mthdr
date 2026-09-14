module Admin
  module Authors
    class OpenLibrarySearchesController < AdminController
      before_action :fetch_author

      def create
        task = Admin::OpenLibraryAuthorSearchTask.setup(@author)
        task.enqueue_for_processing!
        redirect_to admin_author_path(@author), notice: t('notices.admin.open_library_searches.create.success')
      end

      private

      def fetch_author
        @author = Author.find(params[:author_id])
      end
    end
  end
end
