class SendReportJob < Job

  def perform
    log_section "Sending report for mailbox #{mailbox.id}..." do
      MailboxDataFetcher.fetch_mailbox(mailbox)
      ReportMailer.send_daily_summary(mailbox).deliver
    end
  end

end

