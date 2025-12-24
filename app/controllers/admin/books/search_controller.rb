module Admin
  module Books
    class SearchController < AdminController
      def create
        redirect_to admin_books_search_path(key: params[:key])
      end

      def show
        @key = params[:key]
        @books = perform_search
      end

      private

      def perform_search
        return [] if @key.blank?

        Book.preload(:author).where('title LIKE ?', "%#{@key}%").order(id: :desc).to_a
      end
    end
  end
end
