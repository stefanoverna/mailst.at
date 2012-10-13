class CheckMailboxJob < Job

  def perform
    log_section "Checking mail #{mailbox.id}..." do
      # mailbox = ImapMailbox.new(
      #   email: XX,
      #   host: XX,
      #   port: XX,
      #   encryption: XX,
      #   username: XX,
      #   password: XX
      # )
      # mailbox.credentials_valid? # true/false, no exceptions
      # mailbox.folders # [ "foo", "bar", "sent" ]
      self.result[:valid] = true
    end
  end

end
