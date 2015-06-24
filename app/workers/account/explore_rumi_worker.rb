class Account::ExploreRumiWorker
  include Sidekiq::Worker
  sidekiq_options :backtrace => true

  def perform(account_id)
    begin
      #==================== Initializers
      obj = Account.find(account_id)
      ref_plan_slug = Ref::Plan.first.slug #if we are going to create configuration editor, we need to change ref_plan_slug
      obj_project =  Core::Project.create(account_id: obj.id ,name: "Explore Rumi",license: "Creative Commons Non-Commercial (Any)",ref_plan_slug: ref_plan_slug)
      
      #==================== Cloning First Datastore
      obj_first_data_store_to_clone = Core::DataStore.find(1)
      new_first_table_name = Nestful.post REST_API_ENDPOINT + "#{obj_first_data_store_to_clone.core_project.account.slug}/#{obj_first_data_store_to_clone.core_project.slug}/#{obj_first_data_store_to_clone.slug}/grid/clone", {:token => obj_first_data_store_to_clone.core_project.core_tokens.first.api_token}, :format => :json
      obj_first_data_store_to_clone.increase_clone_count
      obj_first_data_store_to_clone.create_clone(new_first_table_name["table_name"], obj_project.id)
      
      #==================== Cloning Second Datastore
      obj_second_data_store_to_clone = Core::DataStore.find(2)
      new_second_table_name = Nestful.post REST_API_ENDPOINT + "#{obj_second_data_store_to_clone.core_project.account.slug}/#{obj_second_data_store_to_clone.core_project.slug}/#{obj_second_data_store_to_clone.slug}/grid/clone", {:token => obj_second_data_store_to_clone.core_project.core_tokens.first.api_token}, :format => :json
      obj_second_data_store_to_clone.increase_clone_count
      obj_second_data_store_to_clone.create_clone(new_second_table_name["table_name"], obj_project.id)

    rescue => e
      puts e.to_s
    end
  end

end