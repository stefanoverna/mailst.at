class AddLastSnapshotToFolders < ActiveRecord::Migration
  def change
    add_column :folders, :last_snapshot, :text
  end
end
