class Folder < ActiveRecord::Base
  attr_accessible :imap_name, :label, :mailbox_id, :max_seconds_to_process
  belongs_to :mailbox
  validates_presence_of :mailbox, :imap_name, :max_seconds_to_process

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
end
