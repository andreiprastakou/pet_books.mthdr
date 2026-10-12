# frozen_string_literal: true

module FrontendApi
  class UserReadsSharingsController < FrontendApi::BaseController
    def show
      @sharing = UserReadsSharing.find_by!(code: params[:code].to_s.downcase)
    end

    def create
      @sharing = UserReadsSharing.ensure_for!(current_user)
      render :show
    end

    def current
      @sharing = current_user.user_reads_sharing
      return head :not_found if @sharing.nil?

      render :show
    end

    def destroy
      current_user.user_reads_sharing&.destroy!
      head :no_content
    end
  end
end
