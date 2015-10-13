class CoreMailer < ActionMailer::Base
  
  def invite_into_project(invitor, invited_email, project)
    @invitor = invitor
    @project = project
    mail(to: invited_email, subject: "Invitation to collaborate on project: #{@project.slug}", tag: "project-invite-email")
  end
  
	def signup_notification(new_user_email)
		@new_user_email = new_user_email
    mail(to: "support@pykih.com", subject: "[Statistics Dashboard Signup]: #{@new_user_email} <EOM>", tag: "internal").deliver
	end

  def send_account_email_confirmation(core_account_email, account)
    @core_account_email = core_account_email
    @account = account
    @confirmation_url_link = confirmation_account_core_account_email_url(@account,core_account_email) + "?confirmation_token=#{core_account_email.confirmation_token}"
    mail(to: @core_account_email.email, subject: "Statistics Email Confirmation", tag: "new-email-confirmation-email").deliver
  end
  
end