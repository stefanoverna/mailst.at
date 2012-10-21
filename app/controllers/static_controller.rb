class StaticController < ApplicationController
  def home
    if user_signed_in?
      redirect_to dashboard_path
    else
      render "home", layout: "homepage"
    end
  end

  def dashboard
    redirect_to new_user_session_path unless user_signed_in?
  end

  def inboxzero
  end

  def privacy
  end

end
