class MailboxesController < ApplicationController
  load_and_authorize_resource
  inherit_resources

  respond_to :html
  respond_to :json, only: :show
  respond_to :js, only: [ :create, :update, :refresh_folders ]

  def index
    redirect_to dashboard_path
  end

  def create
    @mailbox = Mailbox.new(params[:mailbox])
    @mailbox.user = current_user
    @mailbox.save
    if @mailbox.valid?
      CheckMailboxJob.create(@mailbox)
    end
    respond_with @mailbox
  end

  def refresh_folders
    @mailbox = Mailbox.find(params[:id])
    @mailbox.invalidate_folders!
    CheckMailboxJob.create(@mailbox)
  end

  def send_report
    @mailbox = Mailbox.find(params[:id])
    SendReportJob.create(@mailbox)
    redirect_to @mailbox, notice: "Your report will arrive at your inbox as soon as possible!"
  end

  def update
    @mailbox = Mailbox.find(params[:id])
    @mailbox.update_attributes(params[:mailbox])
    @mailbox.invalidate_fetch!
    if params[:mailbox][:host]
      @mailbox.invalidate_credentials!
      CheckMailboxJob.create(@mailbox)
    end
    respond_with @mailbox
  end

  def mail
    @mailbox = Mailbox.find(params[:id])
    render "report_mailer/send_daily_summary", layout: false
  end

  protected

  def begin_of_association_chain
    @current_user
  end

end
