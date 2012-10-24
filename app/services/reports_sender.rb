class ReportsSender

  def self.report_sending_time(mailbox)
    Time.zone = ActiveSupport::TimeZone[mailbox.timezone]
    now_local = Time.zone.now
    if now_local.hour < mailbox.report_time_hour
      Time.zone.parse("#{mailbox.report_time_hour}:00")
    else
      Time.zone.parse("#{mailbox.report_time_hour}:00") + 1.day
    end
  end

  def self.send!
    mailboxes = if Rails.env.production?
                  Mailbox.with_report_to_be_sent
                else
                  Mailbox.all
                end

    mailboxes.each do |mailbox|
      begin
        MailboxDataFetcher.fetch_mailbox(mailbox)
        ReportMailer.send_daily_summary(mailbox).deliver
      rescue Exception => e
        puts "fallito invio a #{mailbox.username}:\t#{e.class} - #{e.message}"
        puts e.backtrace.join("\n")
      end
    end
  end
end
