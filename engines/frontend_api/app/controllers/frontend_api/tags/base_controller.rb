module FrontendApi
  module Tags
    class BaseController < Api::BaseController
      private

      def fetch_tag
        @tag = Tag.find(params[:id])
      end
    end
  end
end
