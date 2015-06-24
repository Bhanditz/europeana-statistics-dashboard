# == Schema Information
#
# Table name: core_sessions
#
#  id         :integer          not null, primary key
#  session_id :string           not null
#  data       :text
#  created_at :datetime
#  updated_at :datetime
#

# LOCKING this class. Do not change. 
# Module: Access-Control
# Author: Ritvvij Parrikh

class Core::Session < ActiveRecord::Base
  self.table_name = "core_sessions"
  has_one :impl, class_name: "Core::SessionImpl", foreign_key: "session_id", primary_key: "session_id"
end
