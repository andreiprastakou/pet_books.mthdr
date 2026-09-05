# frozen_string_literal: true

module FrontendApi
  module Series
    class SearchController < FrontendApi::Series::BaseController
      def show
        @series_list = ::Series.search_by_name(params[:key]).order(:name).to_a
      end
    end
  end
end
