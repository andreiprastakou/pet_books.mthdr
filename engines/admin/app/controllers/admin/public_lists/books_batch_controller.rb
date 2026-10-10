module Admin
  module PublicLists
    class BooksBatchController < AdminController
      before_action :set_public_list

      def edit
        @books = books_scope
        @membership_roles = stored_membership_roles(@books)
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
        batch = params.fetch(:batch)
        updater.update(batch, on_save: method(:sync_membership)).tap do
          @books = updater.books
          @membership_roles = submitted_membership_roles(batch)
        end
      end

      def sync_membership(book, book_params = nil)
        join = Joins::BookPublicList.find_or_initialize_by(public_list_id: @public_list.id, book_id: book.id)
        assign_membership_role(join, book_params)
        return if join.save

        join.errors.each { |error| book.errors.add(:base, error.full_message) }
      end

      def assign_membership_role(join, book_params)
        return unless membership_submitted?(book_params)

        join.role = book_params.dig(:membership, :role).presence
      end

      def stored_membership_roles(books)
        book_ids = books.filter_map(&:id)
        roles_by_book_id = @public_list.book_public_lists.where(book_id: book_ids).pluck(:book_id, :role).to_h
        books.index_with { |book| roles_by_book_id[book.id] }
      end

      def submitted_membership_roles(batch)
        @books.zip(batch.each_value).to_h do |book, book_params|
          role = book_params.dig(:membership, :role) if membership_submitted?(book_params)
          [book, role.presence]
        end
      end

      def membership_submitted?(book_params)
        book_params.respond_to?(:key?) && book_params.key?(:membership)
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
