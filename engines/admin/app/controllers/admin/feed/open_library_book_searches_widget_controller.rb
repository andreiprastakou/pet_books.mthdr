module Admin
  module Feed
    class OpenLibraryBookSearchesWidgetController < AdminController
      def show
        scope = Admin::OpenLibrarySearchTask.where(status: :fetched).order(Arel.sql('RANDOM()'))
        @tasks = scope.preload(target: :authors).limit(10)
        @tasks_count = scope.count
      end
    end
  end
end
