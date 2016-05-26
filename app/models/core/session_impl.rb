# == Schema Information
#
# Table name: core_session_impls
#
#  id          :integer          not null, primary key
#  session_id  :string
#  account_id  :integer
#  ip          :string
#  device      :string
#  browser     :string
#  blurb       :text
#  created_at  :datetime
#  updated_at  :datetime
#  core_viz_id :integer
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

  # Checks if the user is logged in from multiple sources/devises/browsers.
  #
  # @param aid [Fixnum] id corresponding the user in the database.
  # @return [Object] a Collection active session entries of the user.
  def self.logged_in_from_multiple_sources(aid)
    Core::SessionImpl.joins(:core).includes(:core).where(account_id: aid)
  end

  # Updates or Creates a new Session for the user currently logged in.
  #
  # @param sid [String] securehex string.
  # @param aid [Fixnum] id corresponding the user in the database.
  # @param ip [String] IP address of the user.
  # @param blu [String] the details of browser user is logged in from.
  # @return [Fixnum] the id of the user's session.
  def self.log(sid, aid, ip, blu)
    a = Core::SessionImpl.where(session_id: sid).first
    if a.blank?
      a = Core::SessionImpl.new(session_id: sid)
    end
    a.account_id = aid
    a.ip         = ip
    a.blurb      = blu
    a.save
    return a.id
  end

  #PRIVATE
end
