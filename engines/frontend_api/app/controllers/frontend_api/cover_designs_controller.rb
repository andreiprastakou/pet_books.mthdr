# frozen_string_literal: true

module FrontendApi
  class CoverDesignsController < FrontendApi::BaseController
    def index
      @cover_designs = CoverDesign.all
    end
  end
end
