module Admin
  module Api
    module Books
      class SearchController < ::ApplicationController
        helper Admin::BooksHelper

        def show
          query = params[:q].to_s.strip
          @books = query.present? ? search_scope(query) : []
        end

        private

        def search_scope(query)
          scope = ::Book.preload(:authors)
                        .where('title LIKE ? or original_title LIKE ?', "%#{query}%", "%#{query}%")
          author_ids = Array(params[:author_ids]).compact_blank
          scope = scope.by_author(author_ids).distinct if author_ids.present?
          scope.order(:title).limit(10)
        end
      end
    end
  end
end
