# require "rails_helper"
# RSpec.describe Core::DatacastsController, :type => :controller do
#   describe "GET #run_worker" do

#     it "responds give message" do
#       get :run_worker #{account_id: "europeana_user", project_id: "europeana", id: "spain-item-view"}
#       expect(response).to be_success
#       expect(response).to have_http_status(200)
#     end

#     it "renders message" do
#       get :run_worker #{account_id: "europeana_user", project_id: "europeana", id: "spain-item-view"}
#       expect(flash[:notice]).to match(/^Rerunning the job./)
#       # expect(response).to render_template("index")
#     end
#   end
# end