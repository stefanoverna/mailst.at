class StaticController < ApplicationController
  def home
    render "home", layout: "homepage"
  end

  def dashboard
    redirect_to new_user_session_path unless user_signed_in?
  end

  def email
    @mailbox = Mailbox.first
    render :template => 'report_mailer/send_daily_summary'
  end
end
