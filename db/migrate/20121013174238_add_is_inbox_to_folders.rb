class AddIsInboxToFolders < ActiveRecord::Migration
  def change
    add_column :folders, :is_inbox, :boolean
  end
end
