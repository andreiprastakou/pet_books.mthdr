module Admin
  module Books
    class CollectionBatchController < AdminController
      before_action :set_book
      before_action :ensure_collection

      def edit
        @books = books_scope
      end

      def update
        updater = Admin::BooksBatchUpdater.new
        if apply_via_updater(updater)
          redirect_to admin_book_path(@book), notice: t('notices.admin.books_batch.updates_applied')
        else
          flash.now[:error] = t('notices.admin.books_batch.failed', errors: updater.collect_errors)
          prepare_form_books
          render :edit, status: :unprocessable_content
        end
      end

      private

      def set_book
        @book = Admin::Book.preload(:external_links, :authors).find(params.expect(:book_id))
      end

      def ensure_collection
        head :not_found unless @book.collection?
      end

      def books_scope
        Admin::Book.for_scope(@book.collected_works, :authors, :series, :external_links)
      end

      def apply_via_updater(updater)
        updater.update(params.fetch(:batch), on_save: method(:include_book)).tap do
          @books = updater.books
        end
      end

      def include_book(book, _book_params = nil)
        return if Joins::BookCollection.exists?(collection_id: @book.id, book_id: book.id)

        join = Joins::BookCollection.new(collection: @book, book: book)
        return if join.save

        join.errors.each { |error| book.errors.add(:base, error.full_message) }
      end

      def prepare_form_books
        @books.each { |book| detach_unsaved_new_record(book) }
        ActiveRecord::Associations::Preloader.new(
          records: @books,
          associations: %i[authors series external_links]
        ).call
      end

      def detach_unsaved_new_record(book)
        return unless book.previously_new_record?
        return if book.id.present? && Admin::Book.exists?(book.id)

        book.id = nil
        book.instance_variable_set(:@new_record, true)
      end
    end
  end
end
