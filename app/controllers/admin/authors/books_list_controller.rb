require 'csv'

module Admin
  module Authors
    class BooksListController < AdminController
      before_action :fetch_author, only: %i[create edit]
      before_action :fetch_task, only: %i[edit]

      def create
        task = Admin::AuthorBooksListTask.setup(@author)
        Admin::DataFetchJob.perform_later(task.id)
        redirect_to admin_author_path(@author), notice: t('notices.admin.author_books_list.create.success')
      end

      def edit
        prepare_form_data
      end

      private

      def fetch_author
        @author = Author.find(params[:author_id])
      end

      def fetch_task
        @task = Admin::AuthorBooksListTask.find(params[:id])
      end

      def prepare_form_data
        @books = @author.books.to_a
        @task.fetched_data.each do |attributes|
          next if apply_to_existing_book(attributes)

          book = build_book(attributes)
          @books.push book
        end
      end

      def apply_to_existing_book(attributes)
        existing_book = @books.find do |book|
          book.title == attributes['title'] ||
            (attributes['original_title'].present? && book.original_title == attributes['original_title'])
        end
        return false if existing_book.blank?

        existing_book.assign_attributes(attributes)
        true
      end

      def build_book(attributes)
        Book.new(attributes.merge(author: @author))
      end
    end
  end
end
