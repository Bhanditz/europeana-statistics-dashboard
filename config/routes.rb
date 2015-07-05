require 'sidekiq/pro/web'
Rails.application.routes.draw do
  
  authenticate :account, lambda { |u| u.is_admin? } do
    mount Sidekiq::Web, at: '/workers.engine'
  end

  devise_for :accounts, :controllers => { :registrations => 'core/registrations' }, :path => 'accounts', :path_names => {:sign_up => 'get_in_only_while_rumi_is_in_beta_version'}

  #NORMAL ROUTES --------------------------------------------------------------

  resources :accounts do
    get "revoke_session", on: :member
    namespace :core do
      resources :account_emails do
        get "confirmation", "resend_confirmation", on: :member
      end
      resources :permissions
      resources :projects do
        get "members", on: :member
        resources :db_connections, except: [:show]
        resources :datacasts, except: [:index] do
          post "preview","upload", on: :collection
          get "file", on: :collection
        end
        resources :tokens
        resources :data_stores do
          post "upload", on: :collection
          resources :vizs, only: [:create, :update, :destroy] do
            put "update_only_query", on: :member
          end
        end
        resources :datacast_pulls,only: [:create,:destroy,:edit,:update]
        resources :cards
      end
    end
  end

  #CUSTOM PUBLIC URLs --------------------------------------------------------------
  
  get 'switch_user' => 'switch_user#set_current_user'
  get 'approve/account/:id' => "accounts#change_approval"  
  get "/new", to: "core/projects#new", as: "_new_project"

  #
  get "/:account_id/projects", to: "accounts#show", as: "_account", :defaults => { :content => "projects" }
  get "/:account_id/dashboard", to: "accounts#dashboard", as: "dashboard"
  get "/:account_id/edit", to: "accounts#edit", as: "_edit_account"
  #
  get "/:account_id/:project_id", to: "core/projects#show", as: "_account_project"
  get "/:account_id/:project_id/edit", to: "core/projects#edit", as: "_edit_account_project"
  #
  get "/:account_id/:project_id/data/new", to: "core/data_stores#new", as: "_new_account_project_data_stores"
  get "/:account_id/:project_id/data/:data_id/charts", to: "core/vizs#data_stores", as: "_visualizations_account_project_data_store"
  get "/:account_id/:project_id/data/:data_id/charts/new", to: "core/vizs#new", as: "_new_visualizations_account_project_data_store"
  get "/:account_id/:project_id/data/:data_id/charts/:id/edit", to: "core/vizs#edit", as: "_edit_visualization_account_project_data_store"
  get "/:account_id/:project_id/data/:data_id/charts/:id", to: "core/vizs#show", as: "_visualization_account_project_data_store"
  get "/:account_id/:project_id/data/:data_id/charts/:id/embed", to: "core/vizs#embed", as: "_embed_visualization_account_project_data_store"
  #
  get "/:account_id/:project_id/charts", to: "core/vizs#index", as: "_account_project_vizs"
  #  
  #ROOT URL --------------------------------------------------------------
  root "static_pages#index"

end
