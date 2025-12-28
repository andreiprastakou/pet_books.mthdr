module Admin
  module Api
    module Authors
      class SearchController < ::ApplicationController
        def show
          query = params[:q].to_s.strip
          if query.present?
            @authors = Author.where("fullname LIKE ?", "%#{query}%")
                            .order(:fullname)
                            .limit(10)
          else
            @authors = []
          end
        end
      end
    end
  end
end
