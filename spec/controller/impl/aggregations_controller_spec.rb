# frozen_string_literal: true
require 'rails_helper'
RSpec.describe Impl::AggregationsController, type: :controller do
  before :each do
    controller.class.skip_before_action :authenticate_account!
  end

  describe 'GET #index' do
    it 'responds successfully with an HTTP 200 status code' do
      get :index, account_id: accounts(:europeana_account).id, project_id: core_projects(:europeana_project).id
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #edit' do
    it 'responds successfully with an HTTP 200 status code' do
      get :edit, account_id: accounts(:europeana_account).id, project_id: core_projects(:europeana_project).id, id: impl_aggregations(:france_aggregation).id
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST #create' do
    before do
      allow(subject).to receive(:current_account) { accounts(:europeana_account) }
    end
    it 'responds successfully with an HTTP 200 status code' do

      post :create, account_id: accounts(:europeana_account).id,
           project_id: core_projects(:europeana_project).id,
           impl_aggregation: {
               core_project_id: core_projects(:europeana_project).id,
               genre: 'country',
               name: 'narnia'
           }
      new_aggregation = Impl::Aggregation.find_by(genre: 'country', name: 'narnia')
      expect(response).to redirect_to edit_account_project_impl_aggregation_path(accounts(:europeana_account).id, core_projects(:europeana_project).friendly_id, new_aggregation)
    end
  end

  describe 'GET #update' do

  end

  describe 'GET #destroy' do

  end

  describe 'GET #restart_worker' do
  end

  describe 'GET #providers' do

  end

  describe 'GET #data_providers' do

  end

  describe 'GET #countries' do

  end

  describe 'GET #countrieslist' do

  end
end
