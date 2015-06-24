# == Schema Information
#
# Table name: cerebro_works
#
#  id                 :integer          not null, primary key
#  cerebro_account_id :integer
#  start_date         :string(255)
#  end_date           :string(255)
#  title              :string(255)
#  is_primary         :string(255)
#  name               :string(255)
#  is_current         :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

class Cerebro::Work < ActiveRecord::Base
  
  #GEMS
  self.table_name = "cerebro_works"
  
  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  belongs_to :cerebro_account, class_name: "Cerebro::Account", foreign_key: "cerebro_account_id"
  
  #VALIDATIONS
  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS
  
  def self.extract(ca, organizations)
    if organizations.present?
      if organizations.first.present?
        organizations.each do |w|
          wk = ca.cerebro_works.where(title: w["title"], name: w["name"]).first
          if wk.blank?
            wk = Cerebro::Work.new(cerebro_account_id: ca.id, title: w["title"], name: w["name"])
          end
          wk.start_date = w["startDpate"]
          wk.end_date   = w["endDate"]
          wk.is_primary = w["isPrimary"]
          wk.is_current = w["isCurrent"]
          wk.save
        end
      end
    end
  end
  
  #PRIVATE
  private
  
end
