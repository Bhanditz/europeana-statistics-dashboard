# frozen_string_literal: true
require 'rails_helper'
RSpec.describe Impl::BlacklistDatasetsController, type: :controller do
  before :each do
    controller.class.skip_before_action :authenticate_account!
  end

  describe 'GET#index' do
    it 'should list all the blacklisted datasets' do
      get :index, account_id: accounts(:europeana_account).id, project_id: core_projects(:europeana_project).id
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST#create' do
    it 'should create a new blacklisting in the database' do
      @request.env['HTTP_REFERER'] = 'http://test.com/europeana'
      post :create, account_id: accounts(:europeana_account).id,
           project_id: core_projects(:europeana_project).id,
           impl_blacklist_dataset: { dataset: 'new_dataset_for_blacklist' }
      new_blacklist_dataset = Impl::BlacklistDataset.find_by(dataset: 'new_dataset_for_blacklist')
      expect(new_blacklist_dataset).not_to be_nil
      expect(response).to redirect_to 'http://test.com/europeana'
    end
  end

  describe 'DELETE#destroy' do
    it 'should delete the blacklisting from the database' do
      @request.env['HTTP_REFERER'] = 'http://test.com/europeana'
      delete :destroy, account_id: accounts(:europeana_account).id,
             project_id: core_projects(:europeana_project).id,
             id: impl_blacklist_datasets(:ag_eu_bhl).id
      expect(response).to redirect_to 'http://test.com/europeana'
      expect(Impl::BlacklistDataset.where(dataset: '08701_Ag_EU_BHL').count).to eq(0)
    end
  end


end