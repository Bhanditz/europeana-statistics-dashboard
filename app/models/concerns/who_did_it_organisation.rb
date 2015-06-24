module WhoDidItOrganisation
  extend ActiveSupport::Concern

  included do
    after_create :log_who_created_organisation
    after_update :log_who_updated_organisation
    before_destroy :log_who_destroyed_organisation
  end
  
  private

  def log_who_created_organisation
    a = (self.has_attribute?(:organisation_id) && self.organisation_id.present?) ? self.organisation_id : (self.has_attribute?(:account_id) && self.account_id.present?) ? self.account_id : (self.has_attribute?(:accountable_type) && self.accountable_type == "Organisation") ? self.id : nil
    if self.class.to_s == "Core::Permission"
      m = Core::SessionAction::JOINED
      msg = self.core_team.present? ? "<strong>#{self.email}</strong> joined <strong>#{ self.core_team.name }</strong>" : "<strong>#{self.email}</strong>"
    else
      msg = (self.has_attribute?(:username) && self.username.present?) ? self.username : (self.has_attribute?(:name) && self.name.present?) ? self.name : nil
      m =  Core::SessionAction::CREATED
    end
    Core::SessionAction.log_organisation_activity(m, a, self,msg) if a.present?
    true
  end
  
  def log_who_updated_organisation
    a = (self.has_attribute?(:organisation_id) && self.organisation_id.present?) ? self.organisation_id : (self.has_attribute?(:account_id) && self.account_id.present?) ? self.account_id : (self.has_attribute?(:accountable_type) && self.accountable_type == "Organisation") ? self.id : nil
    msg = (self.has_attribute?(:username) && self.username.present?) ? self.username : (self.has_attribute?(:name) && self.name.present?) ? self.name : nil
    Core::SessionAction.log_organisation_activity(Core::SessionAction::UPDATED, a, self,msg) if a.present?
    true
  end
  
  def log_who_destroyed_organisation
    a = (self.has_attribute?(:organisation_id) && self.organisation_id.present?) ? self.organisation_id : (self.has_attribute?(:account_id) && self.account_id.present?) ? self.account_id : nil
    if self.class.to_s == "Core::Permission"
      m = Core::SessionAction::REMOVED
      msg = self.core_team.present? ? "<strong>#{self.email}</strong> was removed from <strong>#{ self.core_team.name }</strong>" : "<strong>#{self.email}</strong>"
    else
      m = Core::SessionAction::DELETED
      msg = (self.has_attribute?(:username) && self.username.present?) ? self.username : (self.has_attribute?(:name) && self.name.present?) ? self.name : nil
    end
    Core::SessionAction.log_organisation_activity(m, a, self, msg) if a.present?
    true
  end

end