module Admin
  module Authors
    class ListParsingController < AdminController
      before_action :fetch_author, only: %i[new create edit]
      before_action :fetch_task, only: %i[edit]

      def new
      end

      def create
        task = Admin::AuthorBooksListParsingTask.setup(@author, text: params[:text])
        Admin::DataFetchJob.perform_later(task.id)
        redirect_to admin_author_path(@author), notice: t('notices.admin.author_books_list_parsing.create.success')
      end

      def edit
        prepare_form_data
      end

      private

      def fetch_author
        @author = Author.find(params[:author_id])
      end

      def fetch_task
        @task = Admin::AuthorBooksListParsingTask.find(params[:id])
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
          book.title == attributes['title']
        end
        return false if existing_book.nil?

        existing_book.year_published = attributes['year'] if attributes['year'].present?
        existing_book.literary_form = attributes['type'] if attributes['type'].present?
        true
      end

      def build_book(attributes)
        Book.new(
          author: @author,
          title: attributes['title'],
          year_published: attributes['year'],
          literary_form: attributes['type']
        )
      end
    end
  end
end
