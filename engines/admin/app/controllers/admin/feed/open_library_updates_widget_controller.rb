module Admin
  module Feed
    class OpenLibraryUpdatesWidgetController < AdminController
      SAMPLE_SIZE = 5

      def show
        @book_searches = sample_tasks(
          Admin::Tasks::OpenLibraryBookSearch,
          preload: { target: :authors }
        )
        @book_fetches = sample_tasks(
          Admin::Tasks::OpenLibraryBookFetch,
          preload: { target: { owner: :authors } }
        )
        @author_searches = sample_tasks(
          Admin::Tasks::OpenLibraryAuthorSearch,
          preload: :target
        )
        @author_fetches = sample_tasks(
          Admin::Tasks::OpenLibraryAuthorFetch,
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
