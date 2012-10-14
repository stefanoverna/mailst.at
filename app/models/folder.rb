class Folder < ActiveRecord::Base
  attr_accessible :imap_name, :label, :mailbox_id, :max_seconds_to_process, :is_inbox
  belongs_to :mailbox
  validates_presence_of :mailbox, :imap_name, :max_seconds_to_process
  validates_uniqueness_of :is_inbox, scope: [ :mailbox_id ], allow_blank: true
  validates_uniqueness_of :imap_name, scope: [ :mailbox_id ]

  typed_serialize :last_snapshot, Hash

  class TimeToProcess < Struct.new(:title, :id)
  end

  def self.allowed_times_to_process
    [
      TimeToProcess.new("24 hours", 24.hours),
      TimeToProcess.new("48 hours", 48.hours),
      TimeToProcess.new("3 days", 3.days),
      TimeToProcess.new("4 days", 4.days),
      TimeToProcess.new("5 days", 5.days)
    ]
  end

  def available_imap_folders(mailbox)
    folders = mailbox.available_imap_folders
    folders << imap_name if imap_name.present?
    folders
  end
end
