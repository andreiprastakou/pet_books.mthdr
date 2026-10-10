module FrontendApi
  module Authors
    class FullEntriesController < FrontendApi::Authors::BaseController
      before_action :fetch_author, only: %i[show]

      def show; end

      private

      def fetch_author
        @author = Author.preload(:descriptions, :external_links).find(params[:id])
      end
    end
  end
end
