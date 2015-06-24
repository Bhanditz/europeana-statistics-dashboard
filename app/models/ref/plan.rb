# == Schema Information
#
# Table name: ref_plans
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  slug       :string(255)
#  properties :hstore
#  created_by :integer
#  updated_by :integer
#  created_at :datetime
#  updated_at :datetime
#

class Ref::Plan < ActiveRecord::Base
  
  #GEMS
  self.table_name = "ref_plans"
  include WhoDidIt
  extend FriendlyId
  friendly_id :name, use: :slugged
  
  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  store_accessor :properties, :can_private_public, 
                              :can_configuration_edit, 
                              :can_host_custom_dashboard, 
                              :can_publish_data_store, 
                              :can_visualize_data,
                              :can_publish_visualizations,
                              :can_remove_branding,
                              :storage_space,
                              :price_per_month,
                              :description,
                              :sort_order,
                              :target_customer,
                              :genre,
                              :can_use_apis


  #ASSOCIATIONS
  has_many :core_projects, class: "Core::Project", foreign_key: "core_project_id"
  
  #VALIDATIONS
  #CALLBACKS
  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS
  
  def project_text
    self.can_private_public == "TRUE" ? "Private" : "Public"
  end
  
  def other_text
    if slug == "brahmagupta"
      "<tr><td class='text-center'>1 Public Project</td></tr>".html_safe
    elsif slug == "picasso"
      "<tr><td class='text-center'>1 Private Project</td></tr><tr><td class='text-center'>Data-as-a-service</td></tr><tr><td class='text-center'>Configuration Editor</td></tr><tr><td class='text-center'>Host one custom dashboard</td></tr>".html_safe
    elsif slug == "enterprise"
      "<tr><td class='text-center'>Everything Unlimited</td></tr><tr><td class='text-center'>APIs</td></tr><tr><td class='text-center'>Advanced Security</td></tr>".html_safe
    else
      ""
    end
  end
  
  #PRIVATE
  private
  
end
