# == Schema Information
#
# Table name: core_card_layouts
#
#  id         :integer          not null, primary key
#  name       :string
#  template   :text
#  img        :text
#  sort_order :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Core::CardLayout < ActiveRecord::Base
  #GEMS
  self.table_name = "core_card_layouts"
  #CONSTANTS
  #ATTRIBUTES  
  #ACCESSORS
  #ASSOCIATIONS
  #VALIDATIONS
  validates :name, presence: true
  validates :template, presence: true
  #CALLBACKS  
  #SCOPES
  #CUSTOM SCOPES
  #OTHER
  #FUNCTIONS
end
