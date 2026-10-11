# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Frontend sessions', frontend_session: false do
  let(:password) { AuthHelper::FRONTEND_PASSWORD }

  describe 'GET /login' do
    it 'is public' do
      get '/login'

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Log in')
    end
  end

  describe 'GET /' do
    it 'redirects anonymous visitors to the login page' do
      get '/'

      expect(response).to redirect_to('/login')
    end
  end

  describe 'GET /api/cover_designs.json' do
    it 'rejects anonymous visitors' do
      get '/api/cover_designs.json'

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /login' do
    let!(:user) { create(:user, email: 'reader@example.com', password: password) }

    it 'starts a session and sends the reader to the site' do
      post '/login', params: { email: '  Reader@Example.com ', password: password }

      expect(response).to redirect_to('/')
      follow_redirect!
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(user.email)
    end

    it 'returns to the page that was requested' do
      get '/authors'
      post '/login', params: { email: user.email, password: password }

      expect(response).to redirect_to('/authors')
    end

    it 'rejects a wrong password' do
      post '/login', params: { email: user.email, password: 'not-the-password' }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Invalid email or password.')
    end
  end

  describe 'DELETE /logout' do
    it 'ends the session and shows the login page' do
      user = create(:user, password: password)
      post '/login', params: { email: user.email, password: password }

      delete '/logout'

      expect(response).to redirect_to('/login')
      get '/'
      expect(response).to redirect_to('/login')
    end
  end
end
