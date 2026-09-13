module Admin
  module Feed
    class WikidataUpdatesWidgetController < AdminController
      SAMPLE_SIZE = 5

      def show
        @book_searches = sample_tasks(
          Admin::WikidataSearchTask,
          preload: { target: :authors }
        )
        @book_fetches = sample_tasks(
          Admin::WikidataFetchTask,
          preload: { target: { owner: :authors } }
        )
        @author_searches = sample_tasks(
          Admin::WikidataAuthorSearchTask,
          preload: :target
        )
        @author_fetches = sample_tasks(
          Admin::WikidataAuthorFetchTask,
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
