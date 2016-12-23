# frozen_string_literal: true
require 'rails_helper'
RSpec.describe Core::DatacastsController, type: :controller do
  describe 'GET #run_worker' do
    before :each do
      controller.class.skip_before_action :authenticate_account!
    end

    it 'should asynchroneously queue a worker and redirect back to the previous page' do
      @request.env['HTTP_REFERER'] = 'http://test.com/europeana'
      expect(Core::Datacast::RunWorker).to receive(:perform_async)
      get :run_worker, account_id: accounts(:europeana_account).id, project_id: core_projects(:europeana_project).id, id: core_datacasts(:rijksmuseum_providers_count).id
      expect(response).to redirect_to 'http://test.com/europeana'
    end
  end
end
