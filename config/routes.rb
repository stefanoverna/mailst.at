Mailstat::Application.routes.draw do
  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config

  devise_for :users
  resources :mailboxes do
    member do
      get :refresh_folders
    end
  end
  match "/dashboard" => "static#dashboard"
  match "/email" => "static#email"
  match "/inboxzero" => "static#inboxzero"
  root to: "static#home"
end
