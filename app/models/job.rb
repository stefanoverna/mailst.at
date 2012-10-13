class Job < ActiveRecord::Base
  belongs_to :mailbox
  validates_presence_of :status

  attr_accessible :arguments, :status, :mailbox_id

  typed_serialize :arguments, Hash
  typed_serialize :result, Hash
  typed_serialize :log_lines, Array

  scope :pending, where(:status => "pending")
  scope :succeeded, where(:status => "success")
  scope :failed, where(:status => "failure")
  scope :completed, where("status = ? OR status = ?", "success", "failure")

  default_scope order("updated_at DESC")

  def self.create(mailbox, args = {})
    job = super(
      arguments: args,
      status: "pending",
      mailbox_id: mailbox.id
    )
    Delayed::Job.enqueue(job)
    job
  end

  def perform
  end

  def param(arg)
    self.arguments[arg]
  end

  def before(job)
    log "job #{job} started"
  end

  def after(job)
    if @delete_after_complete
      self.destroy
    else
      log "job ended"
    end
  end

  def success(job)
    log "job completed"
    update_attribute(:status, "success")
  end

  def error(job, exception)
    log_section "Job Exception" do
      log exception.message
      log exception.backtrace.join("\n")
    end
  end

  def failure
    log "failure"
    update_attribute(:status, "failure")
  end

  def mark_for_deletion!
    @delete_after_complete = true
  end

  private

  def log_section(title)
    log "=== #{title} ==="
    yield
    log "====#{"="*title.length}===="
  end

  def log(text)
    puts text
    if text.lines.count == 1
      self.log_lines << "#{Time.now} -- #{text}"
    else
      self.log_lines << "#{Time.now} --"
      self.log_lines << text
    end
    save
  end

end
