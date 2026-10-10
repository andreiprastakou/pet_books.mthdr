module Admin
  class Series
    class BooksBatchController < AdminController
      before_action :set_series

      def edit
        @books = books_scope
      end

      def update
        updater = Admin::BooksBatchUpdater.new
        if apply_via_updater(updater)
          redirect_to admin_series_path(@series), notice: t('notices.admin.books_batch.updates_applied')
        else
          flash.now[:error] = t('notices.admin.books_batch.failed', errors: updater.collect_errors)
          prepare_form_books
          render :edit, status: :unprocessable_content
        end
      end

      private

      def set_series
        @series = Admin::Series.preload(:external_links).find(params.expect(:series_id))
      end

      def books_scope
        Admin::Book.for_scope(@series.books, :authors, :series, :external_links)
      end

      def apply_via_updater(updater)
        updater.update(params.fetch(:batch)).tap do
          @books = updater.books
        end
      end

      def prepare_form_books
        ActiveRecord::Associations::Preloader.new(
          records: @books,
          associations: %i[authors series external_links]
        ).call
      end
    end
  end
end
