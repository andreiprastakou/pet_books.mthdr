module FrontendApi
  module Authors
    class RefEntriesController < Api::Authors::BaseController
      before_action :fetch_author, only: :show

      def index
        @authors = Author.all
      end

      def show; end
    end
  end
end
