class CheckMailboxJob < Job

  def perform
    log_section "Checking mail #{mailbox.id}..." do
      puts mailbox.attributes
      box = ImapMailbox.new(mailbox.attributes)
      self.result[:valid] = false
      if box.credentials_valid?
        self.result[:valid] = true
        self.result[:folders] = box.folders
        log "mail valid! #{box.folders.inspect}"
      else
        mailbox.destroy
        log "mail invalid!"
      end
    end
  end

end
