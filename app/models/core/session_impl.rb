# == Schema Information
#
# Table name: core_session_impls
#
#  id               :integer          not null, primary key
#  session_id       :string(255)
#  account_id       :integer
#  ip               :string(255)
#  device           :string(255)
#  browser          :string(255)
#  blurb            :text
#  created_at       :datetime
#  updated_at       :datetime
#  core_viz_id      :integer
#  core_map_file_id :integer
#

class Core::SessionImpl < ActiveRecord::Base
  
  #GEMS
  self.table_name = "core_session_impls"
  
  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  belongs_to :account
  has_one :core, class_name: "Core::Session", foreign_key: "session_id", primary_key: "session_id"
  
  #VALIDATIONS
  #CALLBACKS
  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS
  
  def is_active?
    self.core.present?
  end
  
  #Core::SessionImpl.logged_in_from_multiple_sources(aid)
  def self.logged_in_from_multiple_sources(aid)
    Core::SessionImpl.joins(:core).includes(:core).where(account_id: aid)
  end
  
  #Core::SessionImpl.log(sid, aid, ip, blu)
  def self.log(sid, aid, _ip, blu)
    a = Core::SessionImpl.where(session_id: sid).first
    if a.blank?
      a = Core::SessionImpl.new(session_id: sid)
    end
    a.account_id = aid
    a.ip         = _ip
    a.blurb      = blu
    a.save
    return a.id
  end

  def self.log_viz(sid, aid, _ip, blu,viz_id = nil)
    a = Core::SessionImpl.new()
    # a.session_id = sid
    a.account_id = aid
    a.ip         = _ip
    a.blurb      = blu
    a.core_viz_id = viz_id
    a.save
    return a.id
  end

  def self.log_map_file(aid, _ip, blu,core_map_file_id = nil)
    a = Core::SessionImpl.new()
    a.account_id = aid
    a.ip         = _ip
    a.blurb      = blu
    a.core_map_file_id = core_map_file_id
    a.save
    return a.id
  end

  #PRIVATE
  private
  
end
