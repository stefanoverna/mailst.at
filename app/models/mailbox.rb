class Mailbox < ActiveRecord::Base
  attr_accessible :email, :encryption, :host, :password, :port, :username
  belongs_to :user
  has_many :jobs

  validates_presence_of :email, :encryption, :host, :password, :port, :username, :user
  validates_uniqueness_of :email
  validates_numericality_of :port
  validates_format_of :email, :with => /^.+@.+$/i

  class Encryption < Struct.new(:title, :id)
  end

  def self.allowed_encryptions
    [
      Encryption.new("SSL", :ssl),
      Encryption.new("TSL", :tsl),
      Encryption.new("None", :none)
    ]
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

end
