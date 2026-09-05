# frozen_string_literal: true

module FrontendApi
  module Books
    class FullEntriesController < FrontendApi::Books::BaseController
      before_action :fetch_book, only: %i[show]

      def show; end

      private

      def fetch_book
        @book = Book.preload(genres: :genre).find(params[:id])
      end
    end
  end
end
