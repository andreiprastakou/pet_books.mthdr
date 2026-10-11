# frozen_string_literal: true

module Frontend
  class SessionsController < Frontend::ApplicationController
    layout 'frontend'

    skip_before_action :require_frontend_user, only: %i[new create]

    def new
      @email = params[:email].to_s
      redirect_to(consume_frontend_return_path || root_path) if current_user
    end

    def create
      user = User.find_by(email: login_email)
      if user&.authenticate(params[:password].to_s)
        start_session(user)
      else
        reject_login
      end
    end

    def destroy
      reset_session
      redirect_to login_path, status: :see_other
    end

    private

    def start_session(user)
      return_path = consume_frontend_return_path
      reset_session
      session[:user_id] = user.id
      redirect_to return_path || root_path, status: :see_other
    end

    def reject_login
      @email = login_email
      flash.now[:alert] = t('notices.frontend.sessions.invalid')
      render :new, status: :unprocessable_content
    end

    def login_email
      params[:email].to_s.strip.downcase
    end
  end
end
