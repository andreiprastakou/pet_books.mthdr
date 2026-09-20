Admin::Engine.routes.draw do
  scope as: 'admin' do
    resources :ai_chats, only: %i[index show], controller: 'ai/chats'

    namespace :authors do
      resource :search, only: %i[create show], controller: 'search'
    end
    resources :authors do
      scope module: :authors do
        resources :books, only: %i[new]
        resource :sync_status, only: %i[update], controller: 'sync_status'
        resource :wiki_stats, only: %i[update]
        resources :open_library_searches, only: %i[create]
        resources :wikidata_searches, only: %i[create]
        resources :wikipedia_fetches, only: %i[create]
        resources :external_identities, only: [] do
          resources :open_library_fetches, only: %i[create]
          resources :wikidata_fetches, only: %i[create]
          resources :wikidata_works_fetches, only: %i[create]
        end

        resources :books_list, only: %i[create edit] do
          post :apply, on: :member
        end
        resources :list_parsing, only: %i[new create edit] do
          post :apply, on: :member
        end
      end
    end

    namespace :books do
      resource :batch, only: %i[edit update], controller: 'batch'
      resource :search, only: %i[create show], controller: 'search'
      resource :batch_generate_summaries, only: :create, controller: 'batch_generate_summaries'
    end
    resources :books do
      scope module: :books do
        resource :wiki_stats, only: %i[update], controller: 'wiki_stats'
        resources :generative_summaries, only: %i[create edit update] do
          post :apply, on: :member
        end
        resources :open_library_searches, only: %i[create]
        resources :wikidata_searches, only: %i[create]
        resources :library_thing_searches, only: %i[create]
        resources :wikipedia_fetches, only: %i[create]
        resources :external_identities, only: [] do
          resources :open_library_fetches, only: %i[create]
          resources :wikidata_fetches, only: %i[create]
        end
      end
    end

    resources :collections

    namespace :covers do
      resources :cover_designs, except: %i[show]
    end

    namespace :feed do
      resource :ai_works_widget, only: %i[show], controller: 'ai_works_widget'
      resource :gaps_widget, only: %i[show], controller: 'gaps_widget'
      resource :wikipedia_updates_widget, only: %i[show], controller: 'wikipedia_updates_widget'
      resource :wikidata_updates_widget, only: %i[show], controller: 'wikidata_updates_widget'
      resource :open_library_updates_widget, only: %i[show], controller: 'open_library_updates_widget'
      resource :library_thing_updates_widget, only: %i[show], controller: 'library_thing_updates_widget'
    end

    resources :data_fetch_tasks, only: %i[index show] do
      put :verify, on: :member
      put :reject, on: :member
    end

    resources :open_library_book_search_tasks, only: %i[edit] do
      member do
        post :add_work_identity
        post :add_author_identity
      end
    end

    resources :open_library_author_search_tasks, only: %i[edit] do
      member do
        post :add_author_identity
      end
    end

    resources :wikidata_book_search_tasks, only: %i[edit] do
      member do
        post :add_work_identity
      end
    end

    resources :wikidata_author_search_tasks, only: %i[edit] do
      member do
        post :add_author_identity
      end
    end

    resources :library_thing_book_search_tasks, only: %i[edit] do
      member do
        post :add_work_link
      end
    end

    resources :open_library_book_fetch_tasks, only: %i[edit] do
      member do
        post :add_identity
        post :add_author_identity
        post :add_genre_identity
        post :add_series_identity
        post :apply_summary
        post :add_link
      end
    end

    resources :open_library_author_fetch_tasks, only: %i[edit] do
      member do
        post :apply_birth_year
        post :apply_death_year
        post :apply_description
        post :add_identity
        post :add_link
      end
    end

    resources :wikidata_book_fetch_tasks, only: %i[edit] do
      member do
        post :apply_year
        post :apply_literary_form
        post :add_identity
        post :add_author_identity
        post :add_genre_identity
        post :add_series_identity
        post :add_link
        post :add_wikipedia_link
      end
    end

    resources :wikidata_author_fetch_tasks, only: %i[edit] do
      member do
        post :apply_birth_year
        post :apply_death_year
        post :add_identity
        post :add_link
        post :add_wikipedia_link
      end
    end

    resources :wikidata_author_works_fetch_tasks, only: %i[edit] do
      member do
        post :apply_work
      end
    end

    resources :wikipedia_book_fetch_tasks, only: %i[edit] do
      member do
        post :apply_summary
      end
    end

    resources :wikipedia_author_fetch_tasks, only: %i[edit] do
      member do
        post :apply_description
      end
    end

    resources :genres

    resources :public_list_types do
      resources :public_lists, except: %i[index]
    end

    resources :series

    resources :tags

    namespace :api do
      scope constraints: ->(req) { req.format == :json } do
        namespace :authors do
          resource :search, only: :show, controller: 'search'
        end

        namespace :books do
          resource :search, only: :show, controller: 'search'
        end

        namespace :genres do
          resource :search, only: :show, controller: 'search'
        end

        namespace :series do
          resource :search, only: :show, controller: 'search'
        end
      end
    end

    mount MissionControl::Jobs::Engine, at: '/jobs'

    get '/', to: 'feed#show', format: :html, as: :root
  end
end
