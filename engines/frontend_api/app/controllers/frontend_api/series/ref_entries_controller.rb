# frozen_string_literal: true

module FrontendApi
  module Series
    class RefEntriesController < FrontendApi::Series::BaseController
      before_action :fetch_series, only: :show

      def index
        @series_list = ::Series.order(:name)
      end

      def show; end
    end
  end
end
