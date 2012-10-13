Mailstat::Application.routes.draw do
  devise_for :users
  resources :mailboxes do
    resources :folders, only: :index
  end
  match "/dashboard" => "static#dashboard"
  root to: "static#home"
end
