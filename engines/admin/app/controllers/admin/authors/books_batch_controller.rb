module Admin
  module Authors
    class BooksBatchController < AdminController
      before_action :set_author

      def edit
        @books = books_scope
      end

      def update
        updater = Admin::BooksBatchUpdater.new
        if apply_via_updater(updater)
          redirect_to admin_author_path(@author), notice: t('notices.admin.books_batch.updates_applied')
        else
          flash.now[:error] = t('notices.admin.books_batch.failed', errors: updater.collect_errors)
          prepare_form_books
          render :edit, status: :unprocessable_content
        end
      end

      private

      def set_author
        @author = Admin::Author.preload(:external_links).find(params.expect(:author_id))
      end

      def books_scope
        Admin::Book.by_author(@author).preload(authors: :external_links, series: [], external_links: [])
      end

      def apply_via_updater(updater)
        updater.update(params.fetch(:batch)).tap do
          @books = updater.books
        end
      end

      def prepare_form_books
        ActiveRecord::Associations::Preloader.new(
          records: @books,
          associations: { authors: :external_links, series: [], external_links: [] }
        ).call
      end
    end
  end
end
