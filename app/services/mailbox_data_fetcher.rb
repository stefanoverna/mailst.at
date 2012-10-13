class MailboxDataFetcher
  def self.fetch_mailbox(mailbox)
    box = ImapMailbox.new(mailbox.attributes)
    if box.credentials_valid?
      mailbox.folders.each do |folder|
        puts box.folder_mail_summary(
          folder.imap_name,
          DateTime.now - folder.max_seconds_to_process.seconds
        ).inspect
      end
    end
  end
end
