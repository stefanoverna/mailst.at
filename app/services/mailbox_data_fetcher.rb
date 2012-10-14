class MailboxDataFetcher
  def self.fetch_mailbox(mailbox)
    puts mailbox.label
    box = ImapMailbox.new(mailbox.attributes)
    if box.credentials_valid?
      mailbox.folders.each do |folder|
        summary = box.folder_mail_summary(
          folder.imap_name,
          DateTime.now - folder.max_seconds_to_process.seconds
        )
        old_messages = summary[:old_messages] || []
        old_messages.map! do |mail|
          {
            subject: mail.subject.to_s,
            from: mail.header[:from].decoded,
            to: mail.to.map(&:to_s),
            date: mail.date
          }
        end
        puts summary.inspect
        folder.update_attribute(:last_snapshot, summary)
      end
    end
    mailbox.update_attribute(:last_mailbox_fetch_at, DateTime.now)
    box.disconnect
  end
end
