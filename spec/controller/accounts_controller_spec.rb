# require "rails_helper"
# RSpec.describe AccountsController, :type => :controller do
#   describe "POST #update" do
#     it "renders the page edit page with error" do

#       put :update, account: { gravatar_email_id:"europeana_user", name: "", company:"", location:"", bio:"", url:""}

#       expect(response).to render_template(:edit)
#       expect(flash.alert).to match(/^Failed to update./)
#     end
#   end
# end