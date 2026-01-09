module FrontendApi
  module Books
    class SearchController < Api::Authors::BaseController
      def show
        @books = Book.search_by_title(params[:key]).order(:title).to_a
      end
    end
  end
end
