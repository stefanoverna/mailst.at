class RefactorTimezones < ActiveRecord::Migration

  def change
    remove_column :mailboxes, :report_time_minute
  end

end
