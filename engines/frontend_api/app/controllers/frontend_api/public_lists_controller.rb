# frozen_string_literal: true

module FrontendApi
  class PublicListsController < FrontendApi::BaseController
    before_action :fetch_public_list, only: :show

    def show; end

    private

    def fetch_public_list
      @public_list = PublicList.preload(:generic_links, :book_public_lists).find(params[:id])
    end
  end
end
