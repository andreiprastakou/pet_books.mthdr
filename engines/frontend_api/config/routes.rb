FrontendApi::Engine.routes.draw do
  scope constraints: ->(req) { req.format == :json } do
    namespace :authors do
      resources :full_entries, only: %i[show create update destroy]
      resources :index_entries, only: %i[show index]
      resources :ref_entries, only: %i[show index]
      resource :search, only: :show, controller: 'search'
    end

    namespace :books do
      resources :full_entries, only: %i[show]
      resources :index_entries, only: %i[show index]
      resources :ref_entries, only: %i[show index]
      resources :years, only: :index
      resource :search, only: :show, controller: 'search'
    end

    namespace :tags do
      resources :categories, only: :index
      resources :index_entries, only: %i[show index]
      resources :ref_entries, only: %i[show index]
      resource :search, only: :show, controller: 'search'
    end
  end
end
