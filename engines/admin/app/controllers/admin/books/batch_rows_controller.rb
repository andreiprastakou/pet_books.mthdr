module Admin
  module Books
    class BatchRowsController < AdminController
      def show
        book = Admin::Book.preload(authors: :external_links, series: [], external_links: []).find(params[:id])
        render partial: 'admin/books/batch_row', locals: { book: book, index: row_index }
      end

      private

      def row_index
        index = params[:index].to_s
        index.match?(/\A\d+\z/) ? index : Time.current.to_i.to_s
      end
    end
  end
end
