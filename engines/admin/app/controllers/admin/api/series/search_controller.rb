module Admin
  module Api
    module Series
      class SearchController < ::ApplicationController
        def show
          query = params[:q].to_s.strip
          @series = if query.present?
                      ::Series.where('name LIKE ?', "%#{query}%")
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
