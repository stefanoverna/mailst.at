class AddValidatedToMailboxes < ActiveRecord::Migration
  def change
    add_column :mailboxes, :credentials_valid, :boolean
  end
end
