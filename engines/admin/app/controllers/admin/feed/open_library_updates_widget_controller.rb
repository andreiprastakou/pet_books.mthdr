module Admin
  module Feed
    class OpenLibraryUpdatesWidgetController < AdminController
      SAMPLE_SIZE = 5

      def show
        load_book_samples
        load_author_samples
      end

      private

      def load_book_samples
        @book_searches = sample_tasks(Admin::Tasks::OpenLibraryBookSearch, preload: { target: :authors })
        @book_fetches = sample_tasks(Admin::Tasks::OpenLibraryBookFetch, preload: { target: { owner: :authors } })
      end

      def load_author_samples
        @author_searches = sample_tasks(Admin::Tasks::OpenLibraryAuthorSearch, preload: :target)
        @author_fetches = sample_tasks(Admin::Tasks::OpenLibraryAuthorFetch, preload: { target: :owner })
      end

      def sample_tasks(klass, preload:)
        klass.where(status: :fetched)
             .order(Arel.sql('RANDOM()'))
             .preload(preload)
             .limit(SAMPLE_SIZE)
      end
    end
  end
end
