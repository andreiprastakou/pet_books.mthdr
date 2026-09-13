module Admin
  module Books
    class WikidataSearchesController < AdminController
      before_action :fetch_book

      def create
        task = Admin::WikidataSearchTask.setup(@book)
        task.enqueue_for_processing!
        redirect_to admin_book_path(@book), notice: t('notices.admin.wikidata_searches.create.success')
      end

      private

      def fetch_book
        @book = Book.find(params[:book_id])
      end
    end
  end
end
