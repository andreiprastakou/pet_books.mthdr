# frozen_string_literal: true

module FrontendApi
  class PublicListTypesController < FrontendApi::BaseController
    before_action :fetch_public_list_type, only: :show

    def index
      @public_list_types = PublicListType.order(:name)
    end

    def show; end

    private

    def fetch_public_list_type
      @public_list_type = PublicListType.preload(
        :generic_links,
        :public_lists
      ).find(params[:id])
    end
  end
end
