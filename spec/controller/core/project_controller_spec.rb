# frozen_string_literal: true
require 'rails_helper'
RSpec.describe Core::ProjectsController, type: :controller do
  describe 'GET #show' do
    before :each do
      controller.class.skip_before_action :authenticate_account!
    end

    it 'responds successfully with an HTTP 200 status code' do
      get :show, account_id: accounts(:europeana_account).id, project_id: core_projects(:europeana_project).id
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'renders the show template' do
      get :show, account_id: accounts(:europeana_account).id, project_id: core_projects(:europeana_project).id
      expect(response).to render_template('show')
    end
  end
end
