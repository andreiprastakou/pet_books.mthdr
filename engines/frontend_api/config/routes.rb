FrontendApi::Engine.routes.draw do
  scope constraints: ->(req) { req.format == :json } do
    namespace :authors do
      resources :full_entries, only: %i[show create update destroy]
      resources :index_entries, only: %i[show index]
      resources :pins, only: %i[update destroy]
      resources :ref_entries, only: %i[show index]
      resource :search, only: :show, controller: 'search'
    end

    namespace :books do
      resources :full_entries, only: %i[show]
      resources :index_entries, only: %i[show index]
      resources :ref_entries, only: %i[show index]
      resources :pins, only: %i[update destroy]
      resources :reads, only: %i[update destroy]
      resources :years, only: :index
      resource :search, only: :show, controller: 'search'
    end

    resources :user_pins, only: :index

    %i[user_pins_sharings user_reads_sharings].each do |sharing|
      resources sharing, only: %i[create show], param: :code do
        collection do
          get :current
          delete :current, action: :destroy
        end
      end
    end

    resources :public_list_types, only: %i[index show]
    resources :public_lists, only: :show

    resources :cover_designs, only: :index

    namespace :tags do
      resources :categories, only: :index
      resources :index_entries, only: %i[show index]
      resources :ref_entries, only: %i[show index]
      resource :search, only: :show, controller: 'search'
    end

    namespace :series do
      resources :index_entries, only: %i[show index]
      resources :pins, only: %i[update destroy]
      resources :ref_entries, only: %i[show index]
      resource :search, only: :show, controller: 'search'
    end
  end
end
