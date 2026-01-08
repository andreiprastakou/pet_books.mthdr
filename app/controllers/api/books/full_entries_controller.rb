# frozen_string_literal: true

module Api
  module Books
    class FullEntriesController < Api::Books::BaseController
      before_action :fetch_book, only: %i[show]

      protect_from_forgery with: :null_session
      def show; end
    end
  end
end
