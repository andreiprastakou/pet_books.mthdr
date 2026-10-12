# frozen_string_literal: true

module FrontendApi
  module Authors
    class PinsController < FrontendApi::Authors::BaseController
      before_action :fetch_author

      def update
        @pinned = true
        mark_pinned
      end

      def destroy
        @pinned = false
        UserPin.where(user: current_user, entity: @author).delete_all
        render :update
      end

      private

      def mark_pinned
        UserPin.find_or_create_by!(user: current_user, entity: @author)
      rescue ActiveRecord::RecordNotUnique
        nil
      end
    end
  end
end
