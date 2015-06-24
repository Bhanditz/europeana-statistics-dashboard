class Core::RegistrationsController < Devise::RegistrationsController

  before_action :sudo_organisation_owner!, only: [:edit,:update]
  before_action :set_sessions, only: [:edit, :update]
  
  def new
    super
  end
  
  # LOCKING this method. Do not change. 
  # Module: Access-Control
  # Author: Ritvvij Parrikh

  def create
    super
    unless resource.id.nil?
      Core::Permission.where(email: resource.email).update_all(account_id: resource.id, status:  Constants::STATUS_A)
      if Rails.env.production?
        CoreMailer.signup_notification(resource.email)
      end
    end
  end

  def edit
    @enable_express_tour = true
    super
  end
  
  # LOCKING this method. Do not change. 
  # Module: Access-Control
  # Author: Ritvvij Parrikh

  private

  def set_sessions
    @organisations = current_account.organisations
    @sessions = Core::SessionImpl.logged_in_from_multiple_sources(current_account.id)
    @logged_in_from_multiple_sources = @sessions.count
  end

end 