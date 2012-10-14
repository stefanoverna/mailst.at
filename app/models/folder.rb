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

  def nice_name
    if is_inbox?
      "Inbox"
    else
      label.blank? ? imap_name : label
    end
  end

  def total_messages_count
    last_snapshot[:messages_count] || 0
  end

  def overdue_messages_count
    last_snapshot[:old_messages_count] || 0
  end

  def status
    if last_snapshot.present?
      if overdue_messages_count == 100
        :failure
      elsif overdue_messages_count > 50
        :warning
      else
        :success
      end
    else
      :unknown
    end
  end

  def suggestion_status
    o = overdue_messages_count
    t = total_messages_count

    if o == 0 && t == 0
      0
    elsif o == 0 && t <= 20
      1
    elsif o <= 20 && t <= 20
      2
    elsif o <= 20 && t <= 50
      3
    elsif o <= 50 && t <= 50
      4
    elsif o <= 50 && t <= 100
      5
    else
      6
    end
  end

  def suggestion
    Suggestion.where(status: suggestion_status).sample
  end

  def priority_messages
    last_snapshot[:old_messages].map do |m|
      MessagePresenter.new(m)
    end
  rescue
    []
  end

end
