class AddLastMailboxFetchAtToMailboxes < ActiveRecord::Migration
  def change
    add_column :mailboxes, :last_mailbox_fetch_at, :datetime
  end
end
