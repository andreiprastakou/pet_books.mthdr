Frontend::Engine.routes.draw do
  root to: 'home#index'
  get '*path', to: 'home#index', format: :html
end
