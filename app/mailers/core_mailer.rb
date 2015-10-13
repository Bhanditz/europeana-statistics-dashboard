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
  
end