# == Schema Information
#
# Table name: core_session_actions
#
#  id                   :integer          not null, primary key
#  account_id           :integer
#  core_session_impl_id :integer
#  genre                :string(255)
#  organisation_id      :integer
#  project_id           :integer
#  objectable_type      :string(255)
#  objectable_id        :integer
#  created_at           :datetime
#  updated_at           :datetime
#  message              :text
#  count                :integer
#

class Core::SessionAction < ActiveRecord::Base
  
  #GEMS
  self.table_name = "core_session_actions"
  
  #CONSTANTS
  CREATED   = 1 #create
  UPDATED   = 2 #update
  DELETED   = 3 #destroy
  JOINED    = 4 #joined team
  REMOVED   = 5 #removed from team
    
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  belongs_to :account, class_name: "Account", foreign_key: "account_id"
  belongs_to :organisation, class_name: "Account", foreign_key: "organisation_id"
  belongs_to :project, class_name: "Core::Project", foreign_key: "project_id"
  belongs_to :session, class_name: "Core::SessionImpl", foreign_key: "core_session_impl_id"
  belongs_to :objectable, polymorphic: true
  
  #VALIDATIONS
  validates :account_id, presence: true
  
  #CALLBACKS
  before_create :before_create_set
  #SCOPES
  default_scope {order('updated_at DESC')}
  
  #CUSTOM SCOPES
  #FUNCTIONS
  
  def action
    self.genre == CREATED.to_s ? "created" : self.genre == UPDATED.to_s ? "updated" : self.genre == DELETED.to_s ? "deleted" : self.genre == JOINED.to_s ? "joined" : self.genre == REMOVED.to_s ? "removed" : "blbla"
  end
  
  #Core::SessionAction.log_organisation_activity(Core::SessionAction::_, oid, self)
  def self.log_organisation_activity(g, oid, o, msg = nil)
    begin
      t = Core::SessionAction.new(genre: g,
                                  organisation_id: oid,
                                  objectable_type: o.class.to_s, 
                                  objectable_id: o.id,
                                  message: msg)
      t.core_session_impl_id = Thread.current[:s] if (Thread.current[:s].present?)
      t.account_id           = Thread.current[:i] if (Thread.current[:i].present?)
      if t.plus_1_a_duplicate
        t.save
      end
    rescue
    end
    true
  end
  
  #TODO: On delete this might fail (@ab)
  #Core::SessionAction.log_project_activity(Core::SessionAction::_, pid, self)
  def self.log_project_activity(g, pid, o,msg = nil)
    begin
      t = Core::SessionAction.new(genre: g,
                                  project_id: pid,
                                  objectable_type: o.class.to_s, 
                                  objectable_id: o.id,
                                  message: msg)
      t.core_session_impl_id = Thread.current[:s] if (Thread.current[:s].present?)
      t.account_id           = Thread.current[:i] if (Thread.current[:i].present?)
      t.organisation_id       = t.project.account_id
      if t.plus_1_a_duplicate
        t.save
      end
    rescue 
    end
    true
  end
  
  def plus_1_a_duplicate
    a = Core::SessionAction.where(account_id: self.account_id, core_session_impl_id: self.core_session_impl_id, genre: self.genre.to_s, organisation_id: self.organisation_id, project_id: self.project_id, objectable_type: self.objectable_type, objectable_id: self.objectable_id).first
    if a.present?
      a.update_attributes(count: a.count + 1)
      return false
    else
      return true
    end
  end
  
  #PRIVATE
  private
  
  def before_create_set
    self.count = 0 if self.count.blank?
    true
  end
  
end
