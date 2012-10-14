class Mailbox < ActiveRecord::Base
  attr_accessible :label, :encryption, :host, :password, :port, :username, :folders_attributes, :timezone, :report_time_hour
  belongs_to :user
  has_many :jobs
  has_many :folders
  accepts_nested_attributes_for :folders

  validates_presence_of :label, :encryption, :host, :password, :port, :username, :user
  validates_numericality_of :port

  validates_inclusion_of :timezone, in: TZInfo::Timezone.all_country_zone_identifiers, if: :credentials_valid?
  validates_presence_of :report_time_hour, if: :credentials_valid?

  validates :folders, :folder_uniqueness => true

  class Encryption < Struct.new(:title, :id)
  end

  def self.allowed_encryptions
    [
      Encryption.new("SSL", :ssl),
      Encryption.new("TSL", :tsl),
      Encryption.new("None", :none)
    ]
  end

  def inbox_folder
    folders.detect do |folder|
      folder.is_inbox
    end
  end

  def defer_folders
    folders.select do |folder|
      !folder.is_inbox
    end
  end

  def build_inbox_folder_if_missing
    unless inbox_folder.present?
      folders.build(
        is_inbox: true,
        max_seconds_to_process: 24.hours
      )
    end
  end

  def check_jobs
    CheckMailboxJob.where(mailbox_id: self)
  end

  def latest_completed_check_job
    check_jobs.completed.first
  end

  def credentials_verified?
    !!latest_completed_check_job
  end

  def credentials_valid?
    credentials_verified? && latest_completed_check_job.result[:valid]
  end

  def available_imap_folders
    if credentials_valid?
      all_folders = latest_completed_check_job.result[:folders]
      all_folders.compact - self.folders.map(&:imap_name).compact
    else
      []
    end
  end

  def zone_offset
    TZInfo::Timezone.get(self.timezone).current_period.utc_offset / 3600
  end

  def self.with_report_to_be_sent
    mailboxes = []
    now_utc = DateTime.now.utc
    puts "Ora sono le #{now_utc.hour}"
    timezone_identifiers = Mailbox.select("DISTINCT(timezone)").map(&:timezone)
    timezone_identifiers.each do |timezone_identifier|
      timezone = TZInfo::Timezone.get(timezone_identifier)
      now_local = timezone.utc_to_local(now_utc)
      puts "In #{timezone_identifier} ora sono le #{now_local.hour}"
      mailboxes += Mailbox.where(
        "last_report_sent_at IS NULL OR (timezone = ? AND report_time_hour <= ? AND last_report_sent_at < ?)",
        timezone_identifier,
        now_local.hour,
        24.hours.ago
      )
    end
    mailboxes
  end

  def send_report!
  end

end
