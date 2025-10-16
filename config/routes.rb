Rails.application.routes.draw do
  root to: 'home#index'

  namespace :api do
    scope constraints: ->(req) { req.format == :json } do
      namespace :authors do
        resources :full_entries, only: %i[show create update destroy]
        resources :index_entries, only: %i[show index]
        resources :ref_entries, only: %i[show index]
        resource :search, only: :show, controller: 'search'
      end

      namespace :books do
        resource :batch, only: :update, controller: 'batch'
        resources :full_entries, only: %i[show create update destroy]
        resources :index_entries, only: %i[show index]
        resources :popularity, only: :update
        resources :ref_entries, only: %i[show index]
        resources :years, only: :index
        resource :search, only: :show, controller: 'search'
      end

      namespace :tags do
        resources :categories, only: :index
        resources :full_entries, only: %i[update destroy]
        resources :index_entries, only: %i[show index]
        resources :ref_entries, only: %i[show index]
        resource :search, only: :show, controller: 'search'
      end
    end
  end

  namespace :admin do
    resources :ai_chats, only: %i[index show], controller: 'ai/chats'

    resources :authors do
      scope module: :authors do
        resources :books, only: %i[new]
        resource :books_list, only: %i[create], controller: 'books_list'
        resource :list_parsing, only: %i[new create], controller: 'list_parsing'
        resource :sync_status, only: %i[update], controller: 'sync_status'
        resource :wiki_stats, only: %i[update]
      end
    end
    resource :authors_search, only: %i[create], controller: 'authors/search'

    namespace :books do
      resource :batch, only: %i[edit update], controller: 'batch'
      resource :search, only: %i[create], controller: 'search'
    end
    resources :books do
      scope module: :books do
        resource :wiki_stats, only: %i[update], controller: 'wiki_stats'
        resources :generative_summaries, only: %i[create edit update] do
          put :reject, on: :member
        end
      end
    end

    namespace :covers do
      resources :cover_designs, except: %i[show]
    end

    namespace :feed do
      resource :books_review_widget, only: %i[show], controller: 'books_review_widget' do
        post :request_summary
      end
    end

    resources :data_fetch_tasks, only: %i[index show]

    resources :genres
    resources :tags

    mount MissionControl::Jobs::Engine, at: '/jobs'

    get '/', to: 'feed#show', format: :html, as: :root
  end

  get '*path', to: 'home#index', format: :html
end
