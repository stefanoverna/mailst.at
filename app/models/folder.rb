class Folder < ActiveRecord::Base
  attr_accessible :imap_name, :label, :mailbox_id, :max_seconds_to_process
end
