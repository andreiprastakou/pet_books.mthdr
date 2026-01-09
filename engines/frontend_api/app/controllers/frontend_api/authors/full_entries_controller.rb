module FrontendApi
  module Authors
    class FullEntriesController < Api::Authors::BaseController
      before_action :fetch_author, only: %i[show]

      protect_from_forgery with: :null_session

      def show; end
    end
  end
end
