module FrontendApi
  module Books
    class BaseController < FrontendApi::BaseController
      private

      def fetch_book
        @book = Book.find(params[:id])
      end
    end
  end
end
