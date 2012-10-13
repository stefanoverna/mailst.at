class RenameEmailToNameInMailboxes < ActiveRecord::Migration

  def change
    rename_column :mailboxes, :email, :label
  end

end
