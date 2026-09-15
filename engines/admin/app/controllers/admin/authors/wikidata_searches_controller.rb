module Admin
  module Authors
    class WikidataSearchesController < AdminController
      before_action :fetch_author

      def create
        task = Admin::Tasks::WikidataAuthorSearch.setup(@author)
        task.enqueue_for_processing!
        redirect_to admin_author_path(@author), notice: t('notices.admin.wikidata_searches.create.success')
      end

      private

      def fetch_author
        @author = Admin::Author.find(params[:author_id])
      end
    end
  end
end
