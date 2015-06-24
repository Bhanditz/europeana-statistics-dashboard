require 'sidekiq/pro/web'
Rails.application.routes.draw do

  namespace :core do
    resources :admins do
      get 'accounts', "organizations", "dictionaries", "map_files", on: :collection
      get "dictionaries/:id/verify",to: "admins#verify_or_unverify_dictionaries",on: :member,as: "verify_or_unverify_dictionaries"
      get "map_files/:id/verify", to: "admins#verify_or_unverify_map_files",on: :member,as: "verify_or_unverify_map_files"
    end
    resources :organisations do
      get "members", "make_enterprise_account", on: :member
      resources :team_projects do
        get "add", on: :collection
      end
      resources :themes
      resources :teams do
        get "in", on: :member
      end
    end
  end
  
  authenticate :account, lambda { |u| u.is_admin? } do
    mount Sidekiq::Web, at: '/workers.engine'
  end

  devise_for :accounts, :controllers => { :registrations => 'core/registrations' }, :path => 'accounts', :path_names => {:sign_up => 'get_in_only_while_rumi_is_in_beta_version'}

  #NORMAL ROUTES --------------------------------------------------------------

  resources :accounts do
    get "revoke_session", on: :member
    namespace :core do
      resources :account_emails do
        get "confirmation", on: :member
        get "resend_confirmation", on: :member
      end
      resources :map_files, only: [:create,:show,:update,:destroy] do
        get "download", on: :member
      end
      resources :permissions
      resources :projects do
        get "members", on: :member
        resources :custom_dashboards do
          get "pull", on: :member
        end
        resources :tokens
        resources :data_stores do
          post "upload", "commit_merge", on: :collection
          get "empty_grid", "merge", on: :collection
          put "commit_append", "update_assign_metadata", on: :member
          get "publish", "mark_as_dictionary", "mark_as_dataset", "append_rows", "recalibrate_metadata", "assign_metadata", on: :member
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
  get "/open-data", to: "static_pages#open", as: "open_data"
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
  get "/search/data", to: "core/data_stores#open_data", as: "search_open_data"

  #CUSTOM PUBLIC URLs --------------------------------------------------------------
  
  get 'switch_user' => 'switch_user#set_current_user'
  get 'approve/account/:id' => "accounts#change_approval"  
  get "/new", to: "core/projects#new", as: "_new_project"
  get "/data", to: "core/data_stores#index_all", as: "_data_stores"
  #
  get "/:account_id/projects", to: "accounts#show", as: "_account", :defaults => { :content => "projects" }
  get "/:account_id/maps", to: "accounts#show", as: "_account_maps", :defaults => { :content => "maps" }
  get "/:account_id/dashboard", to: "accounts#dashboard", as: "dashboard"
  get "/:account_id/edit", to: "accounts#edit", as: "_edit_account"  
  get "/:account_id/digital-footprint", to: "accounts#digital_footprint", as: "digital_footprint"
  get "/:account_id/mapfiles",to: "core/map_files#index", as: "_account_map_files"
  get "/:account_id/mapfiles/:map_file_id",to: "core/map_files#show",as: "_account_map_file"
  get "/:account_id/mapfiles/:map_file_id/edit", to: "core/map_files#edit",as: "_edit_account_map_file" 
  
  #
  get "/:account_id/:project_id", to: "core/projects#show", as: "_account_project"
  get "/:account_id/:project_id/edit", to: "core/projects#edit", as: "_edit_account_project"
  #
  get "/:account_id/:project_id/data", to: "core/data_stores#index", as: "_account_project_data_stores"
  get "/:account_id/:project_id/data/new", to: "core/data_stores#new", as: "_new_account_project_data_stores"
  get "/:account_id/:project_id/data/:data_id", to: "core/data_stores#show", as: "_account_project_data_store"
  put "/:account_id/:project_id/data/:data_id/clone", to: "core/data_stores#clone", as: "_clone_account_project_data_store"
  get "/:account_id/:project_id/data/:data_id/csv", to: "core/data_stores#csv", as: "_csv_account_project_data_store"
  get "/:account_id/:project_id/data/:data_id/edit", to: "core/data_stores#edit", as: "_edit_account_project_data_store"
  get "/:account_id/:project_id/data/:data_id/map", to: "core/data_stores#map", as: "_map_account_project_data_store"
  get "/:account_id/:project_id/data/:data_id/charts", to: "core/vizs#data_stores", as: "_visualizations_account_project_data_store"
  get "/:account_id/:project_id/data/:data_id/charts/new", to: "core/vizs#new", as: "_new_visualizations_account_project_data_store"
  get "/:account_id/:project_id/data/:data_id/charts/:id/edit", to: "core/vizs#edit", as: "_edit_visualization_account_project_data_store"
  get "/:account_id/:project_id/data/:data_id/charts/:id", to: "core/vizs#show", as: "_visualization_account_project_data_store"
  get "/:account_id/:project_id/data/:data_id/charts/:id/embed", to: "core/vizs#embed", as: "_embed_visualization_account_project_data_store"
  #
  get "/:account_id/:project_id/charts", to: "core/vizs#index", as: "_account_project_vizs"
  #  
  #Social callbacks and url (Auth integrations)---------------------------
  get "/:account_id/:project_id/oauth/", to: "core/project_oauths#index", as: "oauth_account_core_project"
  get "/:account_id/:project_id/oauth/:provider", to: "core/project_oauths#create_sessions", as: "create_session_oauth_account_core_project"
  get "/auth/:provider/callback", to: "core/project_oauths#callback", as: "callback_oauth_account_core_project"
  get "/:project_id/auth/:provider/refresh_token", to: "core/project_oauths#refresh_token", as: "refresh_token_oauth_core_project"
  delete "/:account_id/:project_id/oauth/delete/:oauth_id", to: "core/project_oauths#destroy", as: "destroy_token_oauth_account_core_project"

  #ROOT URL --------------------------------------------------------------
  root "static_pages#index"

end
