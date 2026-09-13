module FrontendApi
  module Authors
    class BaseController < FrontendApi::BaseController
      private

      def fetch_author
        @author = Author.preload(:external_links).find(params[:id])
      end
    end
  end
end
