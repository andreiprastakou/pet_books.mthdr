module Admin
  module PublicLists
    class BooksBatchController < AdminController
      before_action :set_public_list

      def edit
        @books = books_scope
      end

      def update
        updater = Admin::BooksBatchUpdater.new
        if apply_via_updater(updater)
          redirect_to admin_public_list_type_public_list_path(@public_list_type, @public_list),
                      notice: t('notices.admin.books_batch.updates_applied')
        else
          flash.now[:error] = t('notices.admin.books_batch.failed', errors: updater.collect_errors)
          prepare_form_books
          render :edit, status: :unprocessable_content
        end
      end

      private

      def set_public_list
        @public_list_type = Admin::PublicListType.find(params.expect(:public_list_type_id))
        @public_list = Admin::PublicList.preload(:external_links).find(params.expect(:public_list_id))
      end

      def books_scope
        Admin::Book.for_scope(@public_list.books, { authors: :external_links }, :series, :external_links)
      end

      def apply_via_updater(updater)
        updater.update(params.fetch(:batch), on_save: method(:include_new_book)).tap do
          @books = updater.books
        end
      end

      def include_new_book(book)
        return unless book.previously_new_record?
        return if book.public_list_ids.include?(@public_list.id)

        join = Joins::BookPublicList.new(public_list: @public_list, book: book)
        return if join.save

        join.errors.each { |error| book.errors.add(:base, error.full_message) }
      end

      def prepare_form_books
        @books.each { |book| detach_unsaved_new_record(book) }
        ActiveRecord::Associations::Preloader.new(
          records: @books,
          associations: { authors: :external_links, series: [], external_links: [] }
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
