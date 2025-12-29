module Admin
  module Api
    module Books
      class SearchController < ::ApplicationController
        def show
          query = params[:q].to_s.strip
          if query.present?
            @books = ::Book.preload(:authors).where('title LIKE ? or original_title LIKE ?', "%#{query}%", "%#{query}%")
                            .order(:title)
                            .limit(10)
          else
            @books = []
          end
        end
      end
    end
  end
end
