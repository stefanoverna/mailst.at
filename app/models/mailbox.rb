class Mailbox < ActiveRecord::Base
  attr_accessible :label, :encryption, :host, :password, :port, :username, :folders_attributes, :timezone, :report_time_hour, :seconds_between_reports
  belongs_to :user
  has_many :jobs, dependent: :destroy
  has_many :folders, dependent: :destroy
  accepts_nested_attributes_for :folders

  validates_presence_of :label, :encryption, :host, :password, :port, :username, :user
  validates_numericality_of :port

  validates_presence_of :report_time_hour, if: :credentials_valid?
  validates_presence_of :seconds_between_reports, if: :credentials_valid?

  validates :folders, folder_uniqueness: true
  validate :timezone_exists, if: :credentials_valid?

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

  def invalidate_credentials!
    check_jobs.destroy_all
    invalidate_folders!
  end

  def invalidate_folders!
    invalidate_fetch!
    folders.destroy_all
  end

  def invalidate_fetch!
    last_mailbox_fetch_at = nil
    last_report_sent_at = nil
    save
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
    timezone_identifiers = Mailbox.select("DISTINCT(timezone)").map(&:timezone)
    timezone_identifiers.select(&:present?).each do |timezone_identifier|
      timezone = TZInfo::Timezone.get(timezone_identifier)
      now_local = timezone.utc_to_local(now_utc)
      puts "In #{timezone_identifier} ora sono le #{now_local.hour}"
      mailboxes += Mailbox.where(
        "last_report_sent_at IS NULL OR (timezone = ? AND report_time_hour <= ? AND last_report_sent_at < DATE_SUB(NOW(), INTERVAL seconds_between_reports SECOND))",
        timezone_identifier,
        now_local.hour
      )
    end
    mailboxes.uniq
  end

  def report_sent_now!
    update_attribute(:last_report_sent_at, Time.now)
  end

  def sorted_folders
    ([ inbox_folder ] + defer_folders).compact
  end

  def report_sending_time
    ReportsSender.report_sending_time(self)
  end

  def average_status
    if last_mailbox_fetch_at.nil? || folders.count.zero?
      return :unknown
    end

    mapper = {
      success:  1,
      warning:  0,
      failure: -1
    }

    statuses = folders.map do |f|
      mapper[f.status]
    end

    average_status = statuses.sum / folders.count

    if average_status > 0.7
      :success
    elsif average_status < 0.7
      :failure
    else
      :warning
    end

  rescue
    :unknown
  end

  def has_report_infos?
    self.timezone && self.report_time_hour && self.seconds_between_reports
  end

  private

  def timezone_exists
    unless ActiveSupport::TimeZone[self.timezone].present?
      self.errors.add(:timezone, "not valid")
    end
  end

end
