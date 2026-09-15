module Admin
  module Authors
    class BooksController < AdminController
      before_action :set_author

      def new
        @book = Admin::Book.new(authors: [@author])
      end

      private

      def set_author
        @author = Author.find(params.expect(:author_id))
      end
    end
  end
end
