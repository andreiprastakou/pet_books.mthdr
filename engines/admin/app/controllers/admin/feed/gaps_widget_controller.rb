module Admin
  module Feed
    class GapsWidgetController < AdminController
      SAMPLE_SIZE = 5

      def show
        books_scope = Book.preload(:authors, :external_links)
                          .not_filled.without_tasks.form_requires_summary
        @books = books_scope.first(SAMPLE_SIZE)
        @books_count = books_scope.count

        authors_scope = Admin::Author.not_synced.without_tasks
        @authors = authors_scope.first(SAMPLE_SIZE)
        @authors_count = authors_scope.count
      end
    end
  end
end
