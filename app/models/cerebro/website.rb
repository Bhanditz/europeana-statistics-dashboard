# == Schema Information
#
# Table name: cerebro_websites
#
#  id                 :integer          not null, primary key
#  cerebro_account_id :integer
#  url                :text
#  genre              :string(255)
#  handle             :string(255)
#  client             :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

class Cerebro::Website < ActiveRecord::Base
  
  #GEMS
  self.table_name = "cerebro_websites"
  
  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  belongs_to :cerebro_account, class_name: "Cerebro::Account", foreign_key: "cerebro_account_id"
  
  #VALIDATIONS
  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS
  
  def self.extract(ca, websites, g)
    if websites.present?
      if websites.first.present?
        websites.each do |w|
          if g == "Websites"
            wk = ca.cerebro_websites.where(genre: g, url: w["url"]).first
            Cerebro::Website.create(cerebro_account_id: ca.id, genre: g, url: w["url"])  if wk.blank?
          else
            wk = ca.cerebro_websites.where(genre: g, client: w["client"]).first
            wk = Cerebro::Website.new(cerebro_account_id: ca.id, genre: g, client: w["client"])  if wk.blank?
            wk.handle = w["handle"]
            wk.save
          end
        end
      end
    end
  end
  
  #PRIVATE
  private
  
end
