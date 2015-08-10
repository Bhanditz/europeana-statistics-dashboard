# == Schema Information
#
# Table name: impl_static_attributes
#
#  id             :integer          not null, primary key
#  impl_output_id :integer
#  key            :string
#  value          :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Impl::StaticAttribute < ActiveRecord::Base
  #GEMS
  self.table_name = "impl_static_attributes"
  
  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  belongs_to :impl_output, class_name: "Impl::Output", foreign_key: "impl_output_id"
  #VALIDATIONS
  validates :impl_output_id, presence: :true
  validates :key, presence: :true
  validates :value, presence: :true  
  #CALLBACKS
  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS
  def self.create_or_update(impl_output_id, key, value)
    a = where(impl_output_id: impl_output_id, key: key).first
    if a.blank?
      a = create({impl_output_id: impl_output_id, key: key, value: value})
    else
      a.update_attributes(value: value)
    end
    a
  end

  def self.create_or_update_static_data(static_data, impl_output_id)
    static_data.each do |d|
      key = d.keys.first
      value = d.values.first
      self.create_or_update(impl_output_id,key,value)
    end
  end
  #PRIVATE
  private
end