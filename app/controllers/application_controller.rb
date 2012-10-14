class ApplicationController < ActionController::Base
  protect_from_forgery

  def after_sign_in_path_for(resource)
    if current_user.mailboxes.count == 0 || current_user.mailboxes.count > 1
      dashboard_path
    else
      mailbox_path current_user.mailboxes.first
    end
  end

end
