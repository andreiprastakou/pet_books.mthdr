# frozen_string_literal: true

module FrontendApi
  class UserPinsSharingsController < FrontendApi::BaseController
    def show
      @sharing = UserPinsSharing.find_by!(code: params[:code].to_s.downcase)
    end

    def create
      @sharing = UserPinsSharing.ensure_for!(current_user)
      render :show
    end

    def current
      @sharing = current_user.user_pins_sharing
      return head :not_found if @sharing.nil?

      render :show
    end

    def destroy
      current_user.user_pins_sharing&.destroy!
      head :no_content
    end
  end
end
