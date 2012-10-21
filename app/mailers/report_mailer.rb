class ReportMailer < ActionMailer::Base
  default from: "Mailstat <noreply@mailst.at>"

  def send_daily_summary(mailbox)
    @mailbox = mailbox
    mailbox.report_sent_now!
    mail(to: mailbox.user.email, subject: "#{mailbox.label.titleize} mailbox summary")
  end
end
