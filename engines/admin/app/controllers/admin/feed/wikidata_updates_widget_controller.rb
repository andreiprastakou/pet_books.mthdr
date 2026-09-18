module Admin
  module Feed
    class WikidataUpdatesWidgetController < AdminController
      SAMPLE_SIZE = 5

      def show
        load_book_samples
        load_author_samples
      end

      private

      def load_book_samples
        @book_searches = sample_tasks(Admin::Tasks::WikidataBookSearch, preload: { target: :authors })
        @book_fetches = sample_tasks(Admin::Tasks::WikidataBookFetch, preload: { target: { owner: :authors } })
      end

      def load_author_samples
        @author_searches = sample_tasks(Admin::Tasks::WikidataAuthorSearch, preload: :target)
        @author_fetches = sample_tasks(Admin::Tasks::WikidataAuthorFetch, preload: { target: :owner })
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
