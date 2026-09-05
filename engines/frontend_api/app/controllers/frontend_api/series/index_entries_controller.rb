# frozen_string_literal: true

module FrontendApi
  module Series
    class IndexEntriesController < FrontendApi::Series::BaseController
      def index
        @series_list = ::Series.order(:name)
      end

      def show
        @series = ::Series.preload(:generic_links).find(params[:id])
      end
    end
  end
end
