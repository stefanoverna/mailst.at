class Mailbox < ActiveRecord::Base
  attr_accessible :email, :encryption, :host, :password, :port, :username, :folders_attributes, :timezone, :report_time_hour
  belongs_to :user
  has_many :jobs
  has_many :folders
  accepts_nested_attributes_for :folders

  validates_presence_of :email, :encryption, :host, :password, :port, :username, :user
  validates_uniqueness_of :email
  validates_numericality_of :port
  validates_format_of :email, :with => /^.+@.+$/i

  validates_inclusion_of :timezone, in: TZInfo::Timezone.all_country_zone_identifiers
  validates_presence_of :report_time_hour, if: :credentials_valid?

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
    folders.detect do |folder|
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

  def latest_succeeded_check_job
    check_jobs.succeeded.first
  end

  def credentials_verified?
    !!latest_succeeded_check_job
  end

  def credentials_valid?
    credentials_verified? && latest_succeeded_check_job.result[:valid]
  end

  def available_imap_folders
    if credentials_verified?
      all_folders = latest_succeeded_check_job.result[:folders]
      all_folders.compact - self.folders.map(&:imap_name).compact
    else
      []
    end
  end

end
