module Admin
  module Feed
    class WikipediaUpdatesWidgetController < AdminController
      SAMPLE_SIZE = 5

      def show
        @book_fetches, @book_fetches_count = sample_tasks(
          Admin::Tasks::WikipediaBookFetch, preload: { target: :authors }
        )
        @author_fetches, @author_fetches_count = sample_tasks(
          Admin::Tasks::WikipediaAuthorFetch, preload: :target
        )
      end

      private

      def sample_tasks(klass, preload:)
        scope = klass.where(status: :fetched)
        samples = scope.order(Arel.sql('RANDOM()')).preload(preload).limit(SAMPLE_SIZE).to_a
        [samples, scope.count]
      end
    end
  end
end
