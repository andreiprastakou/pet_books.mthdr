module Admin
  module Feed
    class LibraryThingUpdatesWidgetController < AdminController
      SAMPLE_SIZE = 5

      def show
        @book_searches, @book_searches_count = sample_tasks(
          Admin::Tasks::LibraryThingBookSearch, preload: { target: :authors }
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
