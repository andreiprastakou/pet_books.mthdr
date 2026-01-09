Rails.application.routes.draw do
  # Mount engines
  mount Admin::Engine, at: '/admin'
  mount FrontendApi::Engine, at: '/api'
  mount Frontend::Engine, at: '/'

  root to: 'frontend/home#index'
end
