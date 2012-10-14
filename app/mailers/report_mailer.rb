class ReportMailer < ActionMailer::Base
  default from: "noreply@mailst.at"

  def send_daily_summary(mailbox)
    mail(to: 'monti.fabrizio@gmail.com', subject: "FOOO")
  end
end
