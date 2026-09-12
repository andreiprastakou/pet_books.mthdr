module Admin
  module Feed
    class OpenLibraryBookFetchesWidgetController < AdminController
      def show
        scope = Admin::OpenLibraryFetchTask.where(status: :fetched).order(Arel.sql('RANDOM()'))
        @tasks = scope.preload(target: :owner).limit(10)
        @tasks_count = scope.count
      end
    end
  end
end
