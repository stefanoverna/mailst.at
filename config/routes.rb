Mailstat::Application.routes.draw do
  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config

  devise_for :users
  resources :mailboxes do
    member do
      get :refresh_folders
      get :mail
      get :send_report
    end
  end
  match "/dashboard" => "static#dashboard"
  match "/inboxzero" => "static#inboxzero"
  match "/privacy" => "static#privacy"
  root to: "static#home"
end
