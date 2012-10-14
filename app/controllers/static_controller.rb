class StaticController < ApplicationController
  def home
    render "home", layout: "homepage"
  end

  def dashboard
    redirect_to new_user_session_path unless user_signed_in?
  end

  def inboxzero
  end
  
  def privacy
  end
end
