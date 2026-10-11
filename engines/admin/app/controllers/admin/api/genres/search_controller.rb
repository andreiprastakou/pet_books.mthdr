module Admin
  module Api
    module Genres
      class SearchController < Admin::ApplicationController
        def show
          query = params[:q].to_s.strip
          @genres = if query.present?
                      ::Genre.where('name LIKE ?', "%#{query}%")
                             .order(:name)
                             .limit(10)
                    else
                      []
                    end
        end
      end
    end
  end
end
