class MailboxesController < ApplicationController
  load_and_authorize_resource
  inherit_resources

  respond_to :html
  respond_to :json, only: :show

  def create
    @mailbox = Mailbox.new(params[:mailbox])
    @mailbox.user = current_user
    @mailbox.save
    if @mailbox.valid?
      CheckMailboxJob.create(@mailbox)
    end
    respond_with @mailbox
  end

  protected

  def begin_of_association_chain
    @current_user
  end

end
