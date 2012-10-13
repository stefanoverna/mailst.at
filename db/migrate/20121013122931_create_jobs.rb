class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.integer  :mailbox_id
      t.text     :arguments
      t.text     :result
      t.text     :log_lines
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :type
      t.string   :status
      t.timestamps
    end
  end
end
