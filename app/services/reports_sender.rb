class ReportsSender
  def self.send!
    Mailbox.with_report_to_be_sent.each do |mailbox|
      mailbox.send_report!
    end
  end
end
