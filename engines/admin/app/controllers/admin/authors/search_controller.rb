module Admin
  module Authors
    class SearchController < AdminController
      def show
        @key = params[:key]
        @authors = perform_search
      end

      def create
        redirect_to admin_authors_search_path(key: params[:key])
      end

      private

      def perform_search
        return [] if @key.blank?

        Author.preload(:books).where('fullname LIKE ?', "%#{@key}%").order(id: :desc).to_a
      end
    end
  end
end
