# frozen_string_literal: true

module FrontendApi
  module Tags
    class RefEntriesController < Api::Tags::BaseController
      before_action :fetch_tag, only: :show

      def index
        @tags = Tag.preload(:book_tag_connections)
      end

      def show; end
    end
  end
end
