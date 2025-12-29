module Admin
  module Api
    module Books
      class SearchController < ::ApplicationController
        def show
          query = params[:q].to_s.strip
          @books = if query.present?
                     ::Book.preload(:authors).where('title LIKE ? or original_title LIKE ?', "%#{query}%", "%#{query}%")
                           .order(:title)
                           .limit(10)
                   else
                     []
                   end
        end
      end
    end
  end
end
