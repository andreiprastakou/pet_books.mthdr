# frozen_string_literal: true

module FrontendApi
  module Tags
    class CategoriesController < Api::Tags::BaseController
      def index
        @categories = Tag.categories.map { |name, id| { id: id, name: name } }
      end
    end
  end
end
