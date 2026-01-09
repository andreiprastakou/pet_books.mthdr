module FrontendApi
  module Books
    class BaseController < Api::BaseController
      private

      def fetch_book
        @book = Book.find(params[:id])
      end
    end
  end
end
