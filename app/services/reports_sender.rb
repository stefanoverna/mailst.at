class ReportsSender
  def self.send!
    Mailbox.with_report_to_be_sent.each do |mailbox|
      begin
        MailboxDataFetcher.fetch_mailbox(mailbox)
        mailbox.send_report!
        # mailbox.update_attribute(:last_report_sent_at, Time.now)
      rescue Exception => e
        puts "fallito invio a #{mailbox.username}:\t#{e.class} - #{e.message}"
      end
    end
  end
end
