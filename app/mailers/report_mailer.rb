class ReportMailer < ActionMailer::Base
  default from: "noreply@mailst.at"

  def send_daily_summary(mailbox)
    @mailbox = mailbox
    mail(to: @mailbox.username, subject: "Mailstat - Daily summary")
  end
end
