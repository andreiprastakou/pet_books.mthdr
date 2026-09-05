# frozen_string_literal: true

module FrontendApi
  module Series
    class BaseController < FrontendApi::BaseController
      private

      def fetch_series
        @series = ::Series.find(params[:id])
      end
    end
  end
end
