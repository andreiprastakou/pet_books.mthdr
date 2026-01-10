module FrontendApi
  module Authors
    class SearchController < FrontendApi::Authors::BaseController
      def show
        @authors = Author.search_by_name(params[:key]).order(:fullname).to_a
      end
    end
  end
end
