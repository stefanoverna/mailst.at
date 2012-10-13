class CreateFolders < ActiveRecord::Migration
  def change
    create_table :folders do |t|
      t.string :mailbox_id
      t.string :label
      t.string :imap_name
      t.integer :max_seconds_to_process

      t.timestamps
    end
  end
end
