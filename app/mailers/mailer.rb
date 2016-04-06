class Mailer < ActionMailer::Base
  def job_status(send_to, subject)
    @email = send_to
    mail(to: @email, subject: subject + "<EOM>")
  end
 end