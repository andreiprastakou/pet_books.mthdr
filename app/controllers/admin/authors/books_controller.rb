module Admin
  module Authors
    class BooksController < AdminController
      before_action :set_author

      def new
        @book = Book.new(authors: [@author])
        @form = Forms::BookForm.new(@book)
      end

      private

      def set_author
        @author = Author.find(params.expect(:author_id))
      end
    end
  end
end
