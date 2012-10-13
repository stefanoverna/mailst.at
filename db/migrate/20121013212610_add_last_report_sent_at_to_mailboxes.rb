class AddLastReportSentAtToMailboxes < ActiveRecord::Migration
  def change
    add_column :mailboxes, :last_report_sent_at, :datetime
  end
end
