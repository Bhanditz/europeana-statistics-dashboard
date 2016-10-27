# frozen_string_literal: true
Rails.application.routes.draw do
  devise_for :accounts, path: 'accounts', path_names: { sign_up: 'secret_signup_only' }

  resources :accounts, only: [] do
    namespace :core do
      resources :projects, only: [:show] do
        get 'members', on: :member
        resources :datacasts, only: [] do
          get 'run_worker', on: :member
        end
      end
    end
  end

  resources :accounts, only: [] do
    resources :projects do
      namespace :impl do
        resources :aggregations, except: [:show, :new] do
          get 'restart_worker', on: :member
        end
        resources :blacklist_datasets, only: [:index, :create, :destroy]
        resources :reports, except: [:show]
      end
    end
  end

  get '/providers', to: 'impl/aggregations#providers', as: 'providers'
  get '/dataproviders', to: 'impl/aggregations#data_providers', as: 'data_providers'
  get '/countries', to: 'impl/aggregations#countries', as: 'countries'
  get '/countrieslist', to: 'impl/aggregations#countrieslist', as: 'countrieslist'
  get '/europeana', to: 'impl/reports#show', as: 'europeana_report', genre: 'europeana', impl_report_id: 'europeana'
  get '/:manual_report_id', to: 'impl/reports#manual_report', as: 'manual_report'

  get '/v1/datacast/:identifier', to: 'api#datacast', as: 'api_datacast'

  namespace :dataprovider, module: false do
    get ':impl_report_id', to: 'impl/reports#show', as: 'impl_report', genre: 'data_provider'
  end

  namespace :country, module: false do
    get ':impl_report_id', to: 'impl/reports#show', as: 'impl_report', genre: 'country'
  end

  namespace :provider, module: false do
    get ':impl_report_id', to: 'impl/reports#show', as: 'impl_report', genre: 'provider'
  end

  get '/:account_id/edit', to: 'accounts#edit', as: '_edit_account'
  get '/:account_id/:project_id', to: 'core/projects#show', as: '_account_project'

  root 'static_pages#index'
end
