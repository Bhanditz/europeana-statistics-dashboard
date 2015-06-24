module WhoDidItProject
  extend ActiveSupport::Concern

  included do
    after_create :log_who_created_project
    after_update :log_who_updated_project
    before_destroy :log_who_destroyed_project
  end
  
  private

  def log_who_created_project
    a = (self.has_attribute?(:core_project_id) && self.core_project_id.present?) ? self.core_project_id : (self.has_attribute?(:core_team_id) && !self.core_team.nil? && self.core_team.core_projects.count > 0) ? self.core_team.core_projects.first.id : (self.class.to_s == "Core::Project") ? self.id : nil
    m = Core::SessionAction::CREATED
    if self.class.to_s == "Core::Permission"
      m = Core::SessionAction::JOINED
      msg = self.core_team.present? ? "<strong>#{self.email}</strong> joined <strong>#{ self.core_team.name }</strong>" : "<strong>#{self.email}</strong>"
    else
      msg = (self.has_attribute?(:name) && self.name.present?) ? self.name : nil
    end
    Core::SessionAction.log_project_activity(m, a, self,msg) if a.present?
    true
  end
  
  def log_who_updated_project
    a = (self.has_attribute?(:core_project_id) && self.core_project_id.present?) ? self.core_project_id : (self.class.to_s == "Core::Project") ? self.id : nil
    msg = (self.has_attribute?(:name) && self.name.present?) ? self.name : nil
    Core::SessionAction.log_project_activity(Core::SessionAction::UPDATED, a, self,msg) if a.present?
    true
  end
  
  def log_who_destroyed_project
    a = (self.has_attribute?(:core_project_id) && self.core_project_id.present?) ? self.core_project_id : (self.has_attribute?(:core_team_id) && !self.core_team.nil? && self.core_team.core_projects.count > 0) ? self.core_team.core_projects.first.id : (self.class.to_s == "Core::Project") ? self.id : nil
    if self.class.to_s == "Core::Permission"
      m  = Core::SessionAction::REMOVED
      msg = self.core_team.present? ? "<strong>#{self.email}</strong> was removed from <strong>#{ self.core_team.name }</strong>" : "<strong>#{self.email}</strong>"
    elsif self.class.to_s == "Core::TeamProject"
      msg = self.core_project.name
    else
      m = Core::SessionAction::DELETED
      msg = (self.has_attribute?(:name) && self.name.present?) ? self.name : nil
    end
    Core::SessionAction.log_project_activity(m, a, self,msg) if a.present?
    true
  end

end