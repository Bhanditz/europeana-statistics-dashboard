# frozen_string_literal: true
require 'rails_helper'
RSpec.describe Impl::ReportsController, type: :controller do
  describe 'GET#manual_report' do

  end

  describe 'GET#show' do
    context 'when it is a country report' do

    end
    context 'when it is a provider report' do

    end
    context 'when it is a data_provider report' do
      it 'should respond with a succesful response' do
        
        get :show, genre: 'data_provider', impl_report_id: impl_aggregations(:dansknaw_aggregation).impl_report.id
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end
    end
  end

  context 'admin interface' do
    before :each do
      controller.class.skip_before_action :authenticate_account!
    end

    describe 'GET#index' do
      it 'should get a list of the reports' do

      end
    end

    describe 'POST#create' do

    end

    describe 'GET#new' do

    end

    describe 'GET#edit' do

    end

    describe 'PATCH#update' do

    end

    describe 'PUT#update' do

    end

    describe 'DELETE#destroy' do

    end
  end
end