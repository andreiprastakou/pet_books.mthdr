module FrontendApi
  module Authors
    class BaseController < Api::BaseController
      private

      def fetch_author
        @author = Author.find(params[:id])
      end
    end
  end
end
