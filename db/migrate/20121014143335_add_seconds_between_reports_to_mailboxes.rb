class AddSecondsBetweenReportsToMailboxes < ActiveRecord::Migration
  def change
    add_column :mailboxes, :seconds_between_reports, :integer
  end
end
