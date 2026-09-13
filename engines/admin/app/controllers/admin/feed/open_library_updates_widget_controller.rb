module Admin
  module Feed
    class OpenLibraryUpdatesWidgetController < AdminController
      SAMPLE_SIZE = 5

      def show
        @book_searches = sample_tasks(
          Admin::OpenLibrarySearchTask,
          preload: { target: :authors }
        )
        @book_fetches = sample_tasks(
          Admin::OpenLibraryFetchTask,
          preload: { target: { owner: :authors } }
        )
        @author_searches = sample_tasks(
          Admin::OpenLibraryAuthorSearchTask,
          preload: :target
        )
        @author_fetches = sample_tasks(
          Admin::OpenLibraryAuthorFetchTask,
          preload: { target: :owner }
        )
      end

      private

      def sample_tasks(klass, preload:)
        klass.where(status: :fetched)
             .order(Arel.sql('RANDOM()'))
             .preload(preload)
             .limit(SAMPLE_SIZE)
      end
    end
  end
end
