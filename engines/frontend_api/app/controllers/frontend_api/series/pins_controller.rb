# frozen_string_literal: true

module FrontendApi
  module Series
    class PinsController < FrontendApi::Series::BaseController
      before_action :fetch_series

      def update
        @pinned = true
        mark_pinned
      end

      def destroy
        @pinned = false
        UserPin.where(user: current_user, entity: @series).delete_all
        render :update
      end

      private

      def mark_pinned
        UserPin.find_or_create_by!(user: current_user, entity: @series)
      rescue ActiveRecord::RecordNotUnique
        nil
      end
    end
  end
end
