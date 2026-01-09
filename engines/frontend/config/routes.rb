Frontend::Engine.routes.draw do
  root to: 'frontend/home#index'
  get '*path', to: 'frontend/home#index', format: :html
end
