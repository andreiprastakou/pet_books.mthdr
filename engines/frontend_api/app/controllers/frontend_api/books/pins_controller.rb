# frozen_string_literal: true

module FrontendApi
  module Books
    class PinsController < FrontendApi::Books::BaseController
      before_action :fetch_book

      def update
        @pinned = true
        mark_pinned
      end

      def destroy
        @pinned = false
        UserPin.where(user: current_user, entity: @book).delete_all
        render :update
      end

      private

      def mark_pinned
        UserPin.find_or_create_by!(user: current_user, entity: @book)
      rescue ActiveRecord::RecordNotUnique
        nil
      end
    end
  end
end
