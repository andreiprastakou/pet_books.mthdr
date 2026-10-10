# frozen_string_literal: true

module FrontendApi
  module Books
    class IndexEntriesController < FrontendApi::Books::BaseController
      before_action :fetch_book, only: :show

      def index
        @books = Book.where(id: params[:ids]).preload(
          :authors,
          :genres,
          :tag_connections
        )
      end

      def show; end
    end
  end
end
