class AddTimezoneAndReportTimeToMailboxes < ActiveRecord::Migration
  def change
    add_column :mailboxes, :timezone, :string
    add_column :mailboxes, :report_time_hour, :integer
    add_column :mailboxes, :report_time_minute, :integer
  end
end
