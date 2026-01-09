module FrontendApi
  module Tags
    class SearchController < Api::Tags::BaseController
      def show
        @tags = Tag.search_by_name(params[:key]).order(:name).to_a
      end
    end
  end
end
