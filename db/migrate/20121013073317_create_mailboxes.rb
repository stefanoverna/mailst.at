class CreateMailboxes < ActiveRecord::Migration
  def change
    create_table :mailboxes do |t|
      t.string :user_id
      t.string :email
      t.string :host
      t.string :port
      t.string :encryption
      t.string :username
      t.string :password

      t.timestamps
    end
  end
end
