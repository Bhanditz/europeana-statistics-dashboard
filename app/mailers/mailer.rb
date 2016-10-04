# frozen_string_literal: true
class Mailer < ActionMailer::Base
  # Sends email to the email addres given in the param. This mail is sent once the all the jobs for a particular month is completed.
  #
  # @param send_to [String] email address of the receiver.
  # @param subject [String] subject of the email.
  def job_status(send_to, subject)
    @email = send_to
    mail(to: @email, subject: subject + '<EOM>')
  end
end
