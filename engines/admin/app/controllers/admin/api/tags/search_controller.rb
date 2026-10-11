module Admin
  module Api
    module Tags
      class SearchController < ::ApplicationController
        def show
          query = params[:q].to_s.strip
          @tags = if query.present?
                    ::Tag.where('name LIKE ?', "%#{query}%")
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
