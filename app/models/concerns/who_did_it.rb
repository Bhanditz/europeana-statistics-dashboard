#http://stackoverflow.com/questions/7444522/is-it-possible-to-define-a-before-save-callback-in-a-module
#http://stackoverflow.com/questions/14541823/how-to-use-concerns-in-rails-4
#http://railscasts.com/episodes/398-service-objects
module WhoDidIt
  extend ActiveSupport::Concern

  included do
    belongs_to :creator, class_name: "Account", foreign_key: "created_by"
    belongs_to :updator, class_name: "Account", foreign_key: "updated_by"
    before_create :who_created_it
    before_update :who_updated_it
  end
  
  private

  def who_created_it
    self.created_by = Thread.current[:i] if (Thread.current[:i].present? and self.created_by.blank?)
    self.updated_by = Thread.current[:i] if (Thread.current[:i].present? and self.updated_by.blank?)
    true
  end
  
  def who_updated_it
    self.updated_by = Thread.current[:i] if Thread.current[:i].present?
    true
  end

end