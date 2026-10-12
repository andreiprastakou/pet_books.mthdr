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
        @read_book_ids = UserBookRead.read_ids_among(current_user, @books.map(&:id))
      end

      def show; end
    end
  end
end
