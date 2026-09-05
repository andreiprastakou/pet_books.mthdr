# frozen_string_literal: true

module FrontendApi
  module Books
    class FullEntriesController < FrontendApi::Books::BaseController
      before_action :fetch_book, only: %i[show]

      def show; end

      private

      def fetch_book
        @book = Book.preload(
          :generic_links,
          genres: :genre,
          book_public_lists: { public_list: :public_list_type },
        ).find(params[:id])
      end
    end
  end
end
