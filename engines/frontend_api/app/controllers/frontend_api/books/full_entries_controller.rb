# frozen_string_literal: true

module FrontendApi
  module Books
    class FullEntriesController < FrontendApi::Books::BaseController
      before_action :fetch_book, only: %i[show]

      def show; end
    end
  end
end
