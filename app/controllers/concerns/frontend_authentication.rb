# frozen_string_literal: true

module FrontendAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :require_frontend_user
    helper_method :current_user
  end

  private

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = session[:user_id].present? ? User.find_by(id: session[:user_id]) : nil
  end

  def require_frontend_user
    return if current_user

    if request.format.json?
      head :unauthorized
    else
      store_frontend_return_path
      redirect_to '/login'
    end
  end

  def store_frontend_return_path
    return unless request.get?

    path = request.fullpath
    session[:frontend_return_to] = path if safe_frontend_path?(path)
  end

  def consume_frontend_return_path
    path = session.delete(:frontend_return_to)
    path if safe_frontend_path?(path)
  end

  def safe_frontend_path?(path)
    path.is_a?(String) &&
      path.start_with?('/') &&
      !path.start_with?('//') &&
      !path.start_with?('/login') &&
      !path.start_with?('/admin') &&
      !path.start_with?('/api')
  end
end
