module FrontendApi
  module Authors
    class FullEntriesController < FrontendApi::Authors::BaseController
      before_action :fetch_author, only: %i[show]

      def show; end
    end
  end
end
