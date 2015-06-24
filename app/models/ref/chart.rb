# == Schema Information
#
# Table name: ref_charts
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  description      :text
#  img_small        :text
#  genre            :string(255)
#  map              :text
#  api              :text
#  created_by       :integer
#  updated_by       :integer
#  img_data_mapping :string(255)
#  slug             :string(255)
#  combination_code :string(6)
#  source           :string(255)
#  file_path        :string(255)
#  sort_order       :integer
#

class Ref::Chart < ActiveRecord::Base

  #GEMS
  self.table_name = "ref_charts"
  include WhoDidIt
  
  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  #VALIDATIONS
  #validates :name, presence: true

  #CALLBACKS
  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS
  #PRIVATE
  private
end
