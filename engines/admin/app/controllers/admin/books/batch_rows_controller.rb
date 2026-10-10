module Admin
  module Books
    class BatchRowsController < AdminController
      def show
        book = Admin::Book.preload(authors: :external_links, series: [], external_links: []).find(params[:id])
        render partial: 'admin/books/batch_row',
               locals: {
                 book: book,
                 index: row_index,
                 ensure_series: series_to_ensure,
                 ensure_authors: authors_to_ensure,
                 membership_column: membership_column
               }
      end

      private

      def row_index
        index = params[:index].to_s
        index.match?(/\A\d+\z/) ? index : Time.current.to_i.to_s
      end

      def series_to_ensure
        return if params[:ensure_series_id].blank?

        Admin::Series.find_by(id: params[:ensure_series_id])
      end

      def authors_to_ensure
        return if params[:ensure_author_id].blank?

        Admin::Author.find_by(id: params[:ensure_author_id])
      end

      def membership_column
        params[:membership_column].to_s == 'public_list_role' ? 'public_list_role' : nil
      end
    end
  end
end
