module Admin
  module Feed
    class AuthorsReviewWidgetController < AdminController
      before_action :fetch_author, only: %i[request_books_list fill_books_list]

      def show
        fetch_view_data
      end

      def request_books_list
        task = Admin::BookSummaryTask.setup(book)
        Admin::DataFetchJob.perform_later(task.id)

        fetch_view_data
        render :show
      end

      def fill_books_list
        task = Admin::BookSummaryTask.setup(book)
        Admin::DataFetchJob.perform_later(task.id)
      end

      private

      def fetch_author
        @author = Author.find(params[:author_id])
      end

      def fetch_view_data
        authors_scope = Author.not_synced.without_tasks
        @authors_to_sync = authors_scope.first(5)
        @authors_to_sync_count = authors_scope.count

        fetched_lists_to_verify_scope = Admin::AuthorBooksListTask.where(status: :fetched)
        @fetched_lists_to_verify = fetched_lists_to_verify_scope.first(5)
        @fetched_lists_to_verify_count = fetched_lists_to_verify_scope.count

        parsed_lists_to_verify_scope = Admin::AuthorBooksListParsingTask.where(status: :fetched)
        @parsed_lists_to_verify = parsed_lists_to_verify_scope.first(5)
        @parsed_lists_to_verify_count = parsed_lists_to_verify_scope.count
      end
    end
  end
end
