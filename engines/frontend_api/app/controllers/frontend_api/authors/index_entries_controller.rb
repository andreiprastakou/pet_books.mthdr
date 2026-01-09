module FrontendApi
  module Authors
    class IndexEntriesController < Api::Authors::BaseController
      before_action :fetch_author, only: :show

      def index
        authors = Author.all
        authors = apply_sort(authors)
        @count = authors.count
        @authors = paginate(authors)
      end

      def show; end

      private

      def apply_sort(authors_scope)
        case params[:sort_by]
        when 'name' then authors_scope.order(:fullname)
        when 'years' then authors_scope.order(birth_year: :desc)
        else authors_scope
        end
      end

      def paginate(authors_scope)
        authors_scope.page(params.fetch(:page, 1)).per(params.fetch(:per_page, 100))
      end
    end
  end
end
