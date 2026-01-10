module Admin
  module Api
    module Authors
      class SearchController < ::ApplicationController
        def show
          query = params[:q].to_s.strip
          @authors = if query.present?
                       Author.where('fullname LIKE ?', "%#{query}%")
                             .order(:fullname)
                             .limit(10)
                     else
                       []
                     end
        end
      end
    end
  end
end
