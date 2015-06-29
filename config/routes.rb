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
        resources :datacasts do 
          post "preview", on: :collection
        end
        resources :tokens
        resources :data_stores do
          post "upload", on: :collection
          resources :vizs, only: [:create, :update, :destroy] do
            put "update_only_query", on: :member
          end
        end
        resources :data_store_pulls,only: [:create,:destroy,:edit,:update]
      end
    end
  end

  #CUSTOM PUBLIC URLs --------------------------------------------------------------

  get "/refer", to: "static_pages#refer", as: "refer"

  get "/roadmap", to: "static_pages#roadmap", as: "roadmap"
  get "/enterprise", to: "static_pages#enterprise", as: "enterprise"
  get "/privacy", to: "static_pages#privacy", as: "privacy"
  get "/terms", to: "static_pages#terms", as: "terms"
  get "/tour", to: "static_pages#tour", as: "tour"
  get "/enterprise-security", to: "static_pages#security", as: "security"
  get "/pricing", to: "static_pages#pricing", as: "pricing"
  get "/case-studies", to: "static_pages#case_studies", as: "case_studies"
  get "/use-cases/data-journalism", to: "static_pages#data_journalism", as: "_use_cases_data_journalism"
  get "/use-cases/visualizations", to: "static_pages#visualizations", as: "_use_cases_visualizations"
  get "/use-cases/publish-open-data", to: "static_pages#publish_open_data", as: "_use_cases_publish_open_data"


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
