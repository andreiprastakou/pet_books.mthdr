module AuthHelper
  FRONTEND_PASSWORD = 'password123'.freeze

  def authorization_header
    credentials = ActionController::HttpAuthentication::Basic.encode_credentials(
      ENV.fetch('ADMIN_USERNAME'), ENV.fetch('ADMIN_PASSWORD')
    )
    { 'HTTP_AUTHORIZATION' => credentials }
  end

  def sign_in_frontend_user!(user = nil)
    user ||= create(:user, password: FRONTEND_PASSWORD)
    post '/login', params: { email: user.email, password: FRONTEND_PASSWORD }
    user
  end
end
